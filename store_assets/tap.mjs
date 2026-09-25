#!/usr/bin/env node
const fs = require("fs");
const { execSync } = require("child_process");

const WS = process.argv[2];
const LABEL = process.argv[3];
if (!WS || !LABEL) {
  console.error("usage: tap.mjs <ws-url> <label-substring>");
  process.exit(1);
}

const ws = new WebSocket(WS);
let id = 1;
const pending = new Map();
function rpc(method, params = {}) {
  const i = id++;
  return new Promise((resolve, reject) => {
    pending.set(i, { resolve, reject });
    ws.send(JSON.stringify({ jsonrpc: "2.0", id: i, method, params }));
    setTimeout(() => reject(new Error("timeout " + method)), 20000);
  });
}
ws.onmessage = (e) => {
  const msg = JSON.parse(e.data);
  if (msg.id != null && pending.has(msg.id)) {
    pending.get(msg.id).resolve(msg);
    pending.delete(msg.id);
  }
};
ws.onerror = (e) => console.error(e);
ws.onopen = async () => {
  try {
    const vm = await rpc("getVM");
    const iid = vm.result.isolates.find((i) => i.name === "main").id;
    const iso = await rpc("getIsolate", { isolateId: iid });
    const binding = iso.result.libraries.find((l) =>
      /widgets\/binding\.dart$/.test(l.uri)
    );
    const dump = await rpc("ext.flutter.debugDumpSemanticsTreeInTraversalOrder", {
      isolateId: iid,
    });
    const text = dump.result.data;
    fs.writeFileSync("/tmp/semantics_dump.txt", text);
    const needle = LABEL.toLowerCase();
    const blocks = text.split("SemanticsNode#");
    let rect = null;
    let foundLabel = "";
    for (const b of blocks) {
      const lm = b.match(/label: "([^"]+)"/);
      if (!lm) continue;
      if (!lm[1].toLowerCase().includes(needle)) continue;
      if (!/actions: tap/.test(b)) continue;
      const rm = b.match(/Rect.fromLTRB\(([\d.]+), ([\d.]+), ([\d.]+), ([\d.]+)\)/);
      if (!rm) continue;
      rect = rm.slice(1).map(Number);
      foundLabel = lm[1];
      break;
    }
    if (!rect) {
      console.error("not found: " + LABEL);
      process.exitCode = 2;
      ws.close();
      return;
    }
    const x = (rect[0] + rect[2]) / 2;
    const y = (rect[1] + rect[3]) / 2;
    console.log(`tap "${foundLabel}" at ${x.toFixed(1)},${y.toFixed(1)}`);
    const exprDown = `WidgetsBinding.instance.handlePointerEvent(PointerDownEvent(pointer: 7, position: Offset(${x}, ${y})))`;
    const exprUp = `WidgetsBinding.instance.handlePointerEvent(PointerUpEvent(pointer: 7, position: Offset(${x}, ${y})))`;
    const d = await rpc("evaluate", { isolateId: iid, targetId: binding.id, expression: exprDown });
    if (d.error) console.error(JSON.stringify(d.error));
    await new Promise((r) => setTimeout(r, 80));
    const u = await rpc("evaluate", { isolateId: iid, targetId: binding.id, expression: exprUp });
    if (u.error) console.error(JSON.stringify(u.error));
    console.log("ok");
  } catch (err) {
    console.error(err);
    process.exitCode = 1;
  }
  ws.close();
};
