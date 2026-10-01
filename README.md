# Unified Inventory — Aion 4.8 NA

## Download or clone

Repository: [AngelShade/aion-inventory](https://github.com/AngelShade/aion-inventory).

Choose **Code > Download ZIP** on GitHub and extract it, or clone:

```powershell
git clone https://github.com/AngelShade/aion-inventory.git
```

Run `Install-Client.cmd` or `Apply-Server.cmd` from the downloaded/cloned folder. This repository is the inventory patch package; the server operator also needs the matching Aion server source to apply it and build their own GameServer JAR.

## What this adds

- One continuous inventory with **12 columns**.
- **9 visible rows** (108 slots) before scrolling.
- **180 starting slots**. Existing expansion rewards remain unlocked.
- NPC, quest and ticket expansions add **9 slots each**, up to **279 slots**.
- An inventory **Search** field, **Clear** button and match count. Search dims other items and scrolls to the first match. Clear restores the previous scroll position.
- Item movement, sorting, tooltips and item use keep the game's normal behavior. Item positions are saved by the server.

This package contains only the inventory changes. It does not add Transmog, Broker, Warehouse menus, Cash Shop, marketplace pages, gameplay rates or account changes.

## Before starting

**Players:** once your server operator has enabled the enlarged inventory, follow **Step 3 only**. You need Python 3.10+ and the matching client. Git, Java, Maven and the server source are for the server operator.

**Server operators:** complete Steps 1 and 2, then install the client change in Step 3 and have your players do the same.

You need:

1. The **same Aion 4.8 NA English client**, using **bin64**. The installer checks the exact Game.dll version. A different or already customized Game.dll is refused.
2. The matching **Aion server source**, with `pom.xml` and `game-server/src`. Access to only a compiled server JAR is not enough.
3. **Python 3.10 or newer**, **Git**, and your normal **Java/Maven server build tools**. No Python libraries or Java signing tools are needed. The supplied server reference uses JDK 25 and Maven 3.9.

Extract the entire ZIP to an ordinary folder. Run the files from the extracted folder, not from inside the ZIP. The scripts ask for your paths; none of our machine's paths are used.

Before changing the server, make your normal database backup and save a copy of its current JAR and active `config/main/custom.properties`.

## Exactly which folder to enter

The installers open a console and ask you to **paste a full folder path and press Enter**. They do not open a folder picker. In File Explorer, open the correct folder, press **Ctrl+L** to select its address, and copy it into the installer. Paths containing spaces are supported, with or without quotes.

| Action | Folder to enter | How to recognize it |
| --- | --- | --- |
| `Install-Client.cmd` (every player) | Your installed **Aion game root** | Contains `bin64/game.dll`, `Data/ui/game/game.pak` and `L10N/enu/data/data.pak`. |
| `Apply-Server.cmd` (server operator) | Your **top-level server source root** | Contains `pom.xml`, `game-server/src` and `game-server/config/main/custom.properties`. |
| Manual JAR deployment in Step 2 (server operator) | Your **active GameServer folder** | Contains the `libs/game-server-4.8-SNAPSHOT.jar` and `config/main/custom.properties` used when you start GameServer. This is not an installer input. |

**Client example:** if your folders look like this, enter **`D:\Games\Aion 4.8 NA`**:

```text
D:\Games\Aion 4.8 NA\        <-- enter this folder
  bin64\
    game.dll
  Data\ui\game\game.pak
  L10N\enu\data\data.pak
```

Do not enter `bin64`, `Data`, `L10N`, the launcher folder, or this extracted `Inventory-Only` package. For example, `D:\Games\Aion 4.8 NA\bin64` is one level too deep: go up to `Aion 4.8 NA`.

**Server source example:** if your folders look like this, enter **`D:\Servers\AionSource`**:

```text
D:\Servers\AionSource\       <-- enter this folder
  pom.xml
  game-server\
    src\
    config\main\custom.properties
```

Do not enter `game-server`, `src`, `target`, the deployed GameServer folder, or this extracted package. A folder containing only server JARs cannot receive the source patch.

**Deployment example:** if you start GameServer from `D:\Servers\Live\game-server`, Step 2 replaces `D:\Servers\Live\game-server\libs\game-server-4.8-SNAPSHOT.jar` and updates `D:\Servers\Live\game-server\config\main\custom.properties`. Use the actual folder your startup script runs from.

These paths are examples: use your own installation locations. The package can stay in Downloads or another extracted folder; you do not need to copy it into Aion or your server. A wrong or incomplete destination is rejected with a list of missing files before any installation files change.

## Step 1 — Add the server source changes

1. Double-click **Apply-Server.cmd**.
2. Paste the path to your **top-level server source folder** — the folder containing `pom.xml` and `game-server/src`, for example `D:\Servers\AionSource`. Do not enter its `game-server` subfolder.
3. Wait for **Applied eight inventory source changes and two inventory settings**.

The script checks the patch before writing, backs up the eight affected Java files and source configuration, and preserves other settings. The source settings become:

```properties
gameserver.inventory.unified = true
gameserver.cube.expansion_limit = 11
```

NPC-specific limits and ticket levels still apply. Eleven is the combined limit across NPC, quest and ticket expansion credits. Existing characters keep their saved credits: for example, five credits give **225 slots** (180 + 5 × 9). New characters do not receive the old automatic five NPC credits.

No SQL migration or manual change to players' expansion counters is required.

### If the patch says your source differs

The script stops before changing any files. Do not replace whole Java files from someone else's server. Your developer can use `server/inventory-only.patch` to apply just these changes to your version:

| File | Inventory change |
| --- | --- |
| `CustomConfig.java` | Unified inventory switch, base capacity and maximum expansions. |
| `Player.java` | Calculate 180 base slots plus saved expansion credits. |
| `SM_CUBE_UPDATE.java` | Send the enlarged capacity after expansion. |
| `SM_INVENTORY_INFO.java` | Send the same capacity at login. |
| `CubeExpandService.java` | Limit expansion credits to 11 and recheck before charging Kinah. |
| `ExpandInventoryAction.java` | Recheck inventory tickets before consuming them. |
| `PlayerEnterWorldService.java` | Stop automatically granting five NPC expansion credits at login. |
| `PlayerService.java` | Start new characters without the old five NPC expansion credits. |

Then add the two properties above to the source and active server configuration.

## Step 2 — Build and install your GameServer

1. Open PowerShell in your **server source folder**.
2. Run:

```powershell
mvn -pl game-server -am clean package '-Dassembly.skipAssembly=true' '-Dmaven.test.skip=true'
```

3. Confirm Maven finishes with **BUILD SUCCESS**. Your new JAR is:

```text
game-server/target/game-server-4.8-SNAPSHOT.jar
```

4. Have players log out, then shut down GameServer normally so their items are saved.
5. In the **running server folder**, back up the existing `libs/game-server-4.8-SNAPSHOT.jar`. Replace it with the JAR you just built.
6. In that running server's `config/main/custom.properties`, set these two lines once:

```properties
gameserver.inventory.unified = true
gameserver.cube.expansion_limit = 11
```

Keep all other settings. The running server folder may be different from the source folder. Updating only the source config does not update a separate deployed server.

7. Start GameServer normally and check that startup completes without errors.

Build **your own JAR**. This ZIP deliberately does not contain our full GameServer JAR because that would also include our other server changes.

## Step 3 — Install the client inventory

1. Fully close Aion.
2. Double-click **Install-Client.cmd**.
3. Paste your **Aion game root folder** — the folder containing `bin64`, `Data` and `L10N`, for example `D:\Games\Aion 4.8 NA`. Do not enter its `bin64` subfolder or the extracted package folder. Press Enter.
4. Wait for **Installed and verified three inventory files**.
5. Launch your normal **64-bit client**, reconnect, and press **I**.

Install the same client change for every player using this enlarged inventory.

The installer backs up and changes only:

```text
bin64/game.dll
Data/ui/game/game.pak
L10N/enu/data/data.pak
```

Inside each archive, only `inventory_dialog.xml` and `inventory_dialog_new.xml` change. Other entries are checked byte for byte. The DLL is built from the supported original with only inventory and search hooks. `Pub.key`, package signatures, RelicCalc and menu plugins are not touched.

If you get **Game.dll is not the supported clean 4.8 NA build**, use a clean matching client. The installer will not overwrite a DLL that contains someone else's custom changes. Custom signatures on the inventory files are also refused.

## Step 4 — Check it in game

1. Open Inventory. It should show 12 columns, 9 visible rows, Search and Clear, with no Next arrow.
2. Click Search and type part of an item name. Check the cursor, match count and dimming. Click Clear.
3. Scroll down, move an item into an unlocked bottom slot, close/reopen Inventory, then log out and back in. The item should stay in that slot.
4. Use an eligible expansion ticket or claim an inventory expansion quest reward. Capacity should increase by 9 immediately. Slots above your unlocked capacity stay locked.

The native code checks and isolated installation tests are recorded in `validation/RESULTS.txt`. Your own client and server still need this in-game check.

## Restore the previous version

Before reducing capacity, move items out of slots above the old capacity while the enlarged inventory is still active. Otherwise those items may become inaccessible in the smaller inventory. Keep your database backup.

### Client

Fully close Aion. Double-click **Restore-Client.cmd** and enter the backup folder printed during installation. It is inside your client at:

```text
Inventory-backups/<installation date and ID>
```

The script restores the original three files. It refuses to overwrite files changed again after installation.

### Server

Double-click **Restore-Server.cmd** and enter the source backup folder printed by Apply-Server. It is inside this extracted package at:

```text
server/backups/<installation date and ID>
```

Rebuild the restored source. Stop GameServer normally, restore its previous JAR and active configuration (or deploy the rebuilt JAR with unified inventory disabled), then start it. Source restoration alone does not replace a running server JAR. These tools do not alter or restore your database.

## Package contents

- `Install-Client.cmd`, `Apply-Server.cmd`: guided installers.
- `Restore-Client.cmd`, `Restore-Server.cmd`: guided restoration.
- `server/inventory-only.patch`: only the eight Java inventory changes.
- `tools/`: inventory hooks, search layout, archive codec and installer source; no external Python libraries.
- `manifest.json`: exact supported DLL hashes and affected source files.
- `validation/RESULTS.txt`: package verification results.

The installer never downloads files, changes account permissions, resets expansion rewards or edits SQL tables.
