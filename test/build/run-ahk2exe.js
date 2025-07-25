const { exec } = require("child_process");
const path = require("path");
const fs = require("fs");
const readline = require("readline");

const [ahkScript, ahkIcon, ahkOut] = process.argv.slice(2);

if (!ahkScript) {
    console.error("[ERROR] Please provide the AHK script path.");
    process.exit(1);
}

const batPath = path.resolve(__dirname, "alternative-ahk2exe-compile.bat");

if (!fs.existsSync(batPath)) {
    console.error(`[ERROR] Batch file not found: ${batPath}`);
    process.exit(1);
}

let finalOut = ahkOut;
if (finalOut && finalOut.endsWith("\\")) {
    finalOut = path.join(finalOut, path.basename(ahkScript, path.extname(ahkScript)) + ".exe");
}

let cmd = `"${batPath}" "${ahkScript}"`;
if (ahkIcon) cmd += ` -ico "${ahkIcon}"`;
if (finalOut) cmd += ` -out "${finalOut}"`;

console.log("[INFO] Running command:");
console.log(cmd);

exec(cmd, (error, stdout, stderr) => {
    if (error) {
        console.error(`[ERROR] ${error.message}`);
        exec("exit", { shell: true });
        return;
    }
    if (stderr) console.error(stderr);

    console.log(stdout);

    const match = stdout.match(/\[OK\] Compiled: (.+)/);
    if (match) {
        const compiledExe = match[1].trim().replace(/"/g, "");
        console.log(`[INFO] Running compiled file: ${compiledExe}`);

        if (fs.existsSync(compiledExe)) {
            exec(`"${compiledExe}"`);
        } else {
            console.error(`[ERROR] Compiled file not found: ${compiledExe}`);
        }
    } else {
        console.error("[ERROR] Could not detect compiled file path from batch output.");
    }
    exec("exit", { shell: true });
});
