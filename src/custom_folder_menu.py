import os
import gi

# Safely require the loaded Nautilus version (4.1 in your case)
try:
    gi.require_version('Nautilus', '4.1')
except ValueError:
    pass
    
from gi.repository import Nautilus, GObject

class CustomFolderExtension(GObject.GObject, Nautilus.MenuProvider):
    def get_background_items(self, current_folder):
        item = Nautilus.MenuItem(
            name='CustomFolderExtension::Create',
            label='Create New Custom Folder...',
            tip='Create an auto-deleting or secure vault folder',
            icon='folder-new'
        )
        item.connect('activate', self.menu_activate, current_folder)
        return [item]

    def menu_activate(self, menu, current_folder):
        target_path = current_folder.get_location().get_path()
        script_path = os.path.expanduser('~/.local/share/nautilus/scripts/Create Custom Folder')
        
        if target_path:
            os.system(f'cd "{target_path}" && "{script_path}" &')
