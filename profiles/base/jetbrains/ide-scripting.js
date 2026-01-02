/**
 * ==============================================================================
 * FILE: ide-scripting.js
 * DESCRIPTION: An example script for JetBrains IDE scripting.
 *              This script adds a custom action to the Tools menu.
 * ==============================================================================
 */

// All IDE scripting is done through the `com.intellij.openapi.actionSystem.ActionManager`
const ActionManager = com.intellij.openapi.actionSystem.ActionManager.getInstance();

// Create a new action
const myAction = new com.intellij.openapi.actionSystem.AnAction("My Custom Action") {
    actionPerformed(e) {
        // Get the current project
        const project = e.getProject();

        // Show a message dialog
        com.intellij.openapi.ui.Messages.showMessageDialog(
            project,
            "Hello from your custom IDE script!",
            "Custom Action",
            com.intellij.openapi.ui.Messages.getInformationIcon()
        );
    }
};

// Register the action to the "ToolsMenu" group
ActionManager.registerAction("MyCustomActionId", myAction);
const toolsMenu = ActionManager.getAction("ToolsMenu");
if (toolsMenu instanceof com.intellij.openapi.actionSystem.DefaultActionGroup) {
    toolsMenu.add(myAction);
}
