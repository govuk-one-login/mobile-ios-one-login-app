import json
import os
import re
import sys
print("Opened File")
buddy_path = "/usr/libexec/PlistBuddy"
file_path = sys.argv[1]
flags_file = sys.argv[2]
print("filepath", file_path)
print("flagsfile", flags_file)
def run_command(cmd):
    print(cmd)
    os.system(cmd)

if __name__ == '__main__':
    run_command("{0} -c \"Add :StringsTable string 'Root'\" {1}".format(buddy_path, file_path))
    run_command("{0} -c \"Add :PreferenceSpecifiers array\" {1}".format(buddy_path, file_path))

    with open(flags_file, "r") as json_file:
        flags_data = json.load(json_file)

        for index, flag in enumerate(flags_data):
            run_command("{0} -c \"Add :PreferenceSpecifiers: dict\" {1}".format(buddy_path, file_path))

            # Type Add Flag
            run_command("{0} -c \"Add :PreferenceSpecifiers:{1}:Type string 'PSToggleSwitchSpecifier'\" {2}".format(buddy_path, index, file_path))
            run_command("{0} -c \"Add :PreferenceSpecifiers:{1}:Key string '{2}'\" {3}".format(buddy_path, index, flag["name"], file_path))

            title = re.sub(r'([a-z](?=[A-Z])|[A-Z](?=[A-Z][a-z]))', r'\1 ', flag["name"])
            run_command("{0} -c \"Add :PreferenceSpecifiers:{1}:Title string '{2}'\" {3}".format(buddy_path, index, title, file_path))

            default_value = str(flag["isEnabled"]).lower()
            run_command("{0} -c \"Add :PreferenceSpecifiers:{1}:DefaultValue bool {2}\" {3}".format(buddy_path, index, default_value, file_path))
