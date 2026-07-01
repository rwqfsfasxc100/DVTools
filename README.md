# DVTools

A Godot plugin containing a collection of tools that are used to help make mods for ΔV: Rings of Saturn

## Quick Links:

- [Download the plugin](https://github.com/rwqfsfasxc100/DVTools/releases/latest)
- [Installation Instructions](https://github.com/rwqfsfasxc100/DVTools/blob/main/README.md#installation-instructions)
- [Planned feature list](https://github.com/rwqfsfasxc100/DVTools/blob/main/README.md#planned-feature-list)

# Features

### Manifest Editing

Mod manifests can now be modified in-editor, as well as being made visible to the FileSystem dock.

<img width="144" height="69" alt="image" src="https://github.com/user-attachments/assets/9a41f8c0-6bfa-4e92-bd39-5e1c5cb0de97" />

Fully-functional editor in the inspector dock, with coverage for all ManifestV2.2 features.

<img width="408" height="320" alt="image" src="https://github.com/user-attachments/assets/d01a4bf3-edd6-4c41-b3c8-5d895faadec3" />

### Enabled Mod Directory Highlighting

Any mods enabled in the `addedMods` array within the `ModLoader.gd` script (if added by the user) will be highlighted in a bright green in the FileSystem dock.

<img width="425" height="170" alt="image" src="https://github.com/user-attachments/assets/46cc91bb-460f-466b-89d8-466559e1433a" />

Currently does not support modlets.

### ModMain.gd and Mod.manifest Highlighting

Any files that can define mods are highlighted in a light green.

<img width="124" height="100" alt="image" src="https://github.com/user-attachments/assets/dd910c6d-8cd7-4f38-ab0b-852c9d357831" />

# Installation Instructions

1. Download the plugin's zip from the releases page [here](https://github.com/rwqfsfasxc100/DVTools/releases/latest)
2. Locate your ΔV decompile's `project.godot` file.

<img width="275" height="203" alt="image" src="https://github.com/user-attachments/assets/9c3ba0cb-7a2b-4930-803a-56b9f13b4b84" />

   2.1. Don't know how to decompile ΔV? Check the setup guide on the ΔV wiki's modding guide [here.](https://delta-v.kodera.pl/index.php/Writing_Your_Own_Mod#Setup)
   2.2. It is heavily recommend that you make the appropriate adjustments to the `ModLoader.gd` script for modding, check [here](https://delta-v.kodera.pl/index.php/Using_the_Godot_Editor) for instructions.
3. If you do not already have an `addons` folder, create one in the same directory as the `project.godot` file.

<img width="143" height="48" alt="image" src="https://github.com/user-attachments/assets/5353dade-2f77-4375-b3d4-c91b0db8dc12" />

4. Open the `DVTools.zip` file downloaded from the releases page with your preferred program. This guide will use File Explorer's built-in reader, but most tools should be similar. Copy the `DVTools` folder from the zip and into the `addons` folder

<img width="357" height="159" alt="image" src="https://github.com/user-attachments/assets/0e8887fd-a67a-4c68-bc1d-91fdc3d618ae" />
<img width="270" height="146" alt="image" src="https://github.com/user-attachments/assets/8ce8dde6-d1a5-4f5b-9e31-5dd4da6f1450" />

5. Open Godot 3.6 (if you do not have it, download it from [here](https://godotengine.org/download/archive/3.6-stable/) using the build for your operating system).
    5.1. If you haven't imported the decompile into the editor, press 'Import', 'Browse' and locate the same `project.godot` file, 'Open' and then 'Import & Edit'

<img width="755" height="244" alt="image" src="https://github.com/user-attachments/assets/b15684d8-825f-48c3-9da1-bd59badf6ffc" />
<img width="775" height="477" alt="image" src="https://github.com/user-attachments/assets/9c02f118-cfa6-4da4-a06f-85a40725c070" />
<img width="509" height="175" alt="image" src="https://github.com/user-attachments/assets/89ecc6e3-575b-4add-95e6-fbe2628c77c8" />

6. Ensure the plugin is installed. In the top-left of the editor window, select the 'Project' dropdown, then 'Project Settings'. Select the 'Plugins' tab, and if the entry for 'Hev's ΔV Tools' is not enabled, enable it.

<img width="394" height="76" alt="image" src="https://github.com/user-attachments/assets/9ca38503-39d7-49c8-b06d-0b8472dead16" />
<img width="886" height="123" alt="image" src="https://github.com/user-attachments/assets/50ba0177-c484-4d12-b944-b8be342278eb" />

# Planned feature list
- ~~`Manifests`~~
- ~~`Highlighting`~~
  - `Highlight Modlets`
- `ADD_MINERALS.gd`
- `ADD_EQUIPMENT_ITEMS.gd`
- `ADD_EQUIPMENT_SLOTS.gd`
- `EQUIPMENT_TAGS.gd`
- `SLOT_ORDER.gd`
- `SLOT_TAGS.gd`
- `AUX_POWER_AND_THRUSTERS.gd`
- `MODIFY_INTERNALS.gd`
- `NODE_DEFINITIONS.gd`
- `SHIP_NODE_MODIFY.gd`
- `SHIP_NODE_REGISTER.gd` 
- `SHIP_THRUSTER_COLORS.gd`
- `WEAPONSLOT_ADD.gd`
- `WEAPONSLOT_MODIFY_TEMPLATES.gd`
- `WEAPONSLOT_MODIFY.gd`
- `WEAPONSLOT_SHIP_TEMPLATES.gd`
- `WEAPONSLOT_SHIP_MODIFY.gd`
- `SAVE_BUTTONS.gd`
- `ADD_SHIPS.gd`
- `REGISTER_SHIP_NUMERICS.gd`
- `MODIFY_SHIP_NUMERICS.gd`
- `NAMER.gd`
- `LOAD_RESOURCES.gd`
- `MOD_DETAILS.txt`
- `REPLACE_TRANSLATIONS.gd` (If time permits, TranslationTracker already serves this purpose well enough for the time being)
