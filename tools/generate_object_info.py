import argparse
import os
import re
import json

parser = argparse.ArgumentParser(description='Generate tilemap')
parser.add_argument('export_folder', help='path to the folder with exported files')

args = parser.parse_args()
export_folder = args.export_folder.rstrip('/\\')
print("Parsing files in " + export_folder)

def get_value(key, value, is_math=False):
    if re.match(r"^(\d)+$", value):
        return int(value)
    elif re.match(r"^(\d|\.)+$", value):
        return float(value)
    elif is_math:
        result = re.match(r"^(\+|-)(\d+)$", value)
        if result:
            old_val = variables[key] if key in variables else None
            if old_val == 'RUINE_KONTOR_1':
                # TODO
                old_val = 424242
            if result.group(1) == '+':
                return old_val + int(result.group(2))
            elif result.group(1) == '-':
                return old_val - int(result.group(2))
            else:
                raise Exception()
    elif re.match(r"^[A-Za-z0-9_]+$", value):
        return variables[value] if value in variables else value
    elif ',' in value:
        vals = []
        for val in map(str.strip, value.split(',')):
            vals.append(get_value(key, val))
        return vals
    else:
        result = re.match(r"^([A-Z]+|\d+)\+([A-Z]+|\d+)$", value)
        if result:
            val_1 = get_value(key, result.group(1))
            val_2 = get_value(key, result.group(2))
            return val_1 + val_2

    print("invalid value: " + str(value))
    raise Exception(value)

variables = {}
objects = {}

current_object = None
current_nested_object = None
current_item = None

with open(os.path.join(export_folder, 'haeuser.txt'), encoding='utf-8', mode='r') as haeuser_cod:
    for i, line in enumerate(haeuser_cod):
        line = line.split(';', 1)[0].strip()
        if len(line) == 0:
            continue

        # Skipped
        if line.startswith('Nahrung:'):
            # TODO: skipped for now
            continue

        # constant assignment
        result = re.match(r"^(@?)(\w+)\s*=\s*((?:\d+|\+|\w+)+)$", line)
        if result:
            is_math = len(result.group(1)) > 0
            constant = result.group(2)
            value = result.group(3)
            variables[constant] = get_value(constant, value, is_math)
            continue

        result = re.match(r"^ObjFill:\s*(\w+)$", line)
        if result:
            assert(current_object is not None)
            assert(current_item is not None)
            assert(objects[current_object]['items'][current_item] == {'nested_objects': {}})

            base_item_num = get_value(None, result.group(1))
            base_item = objects[current_object]['items'][base_item_num]
            objects[current_object]['items'][current_item] = base_item

        # new (nested) object
        result = re.match(r"^Objekt:\s*(\w+)$", line)
        if result:
            object_name = result.group(1)
            if current_object is None:
                current_object = object_name
                objects[object_name] = {
                    'items': {},
                }
            elif current_nested_object is None:
                assert(current_item is not None)
                current_nested_object = object_name
                objects[current_object]['items'][current_item]['nested_objects'][current_nested_object] = {}
            else:
                raise Exception('Cannot have more than one nesting level!')
            continue

        # end (nested) object
        if line == 'EndObj':
            if current_nested_object is not None:
                current_nested_object = None
            elif current_object is not None:
                current_object = None
                current_item = None
            else:
                raise Exception('Received EndObj without current object!')
            continue


        result = re.match(r"^(@?)(\w+):\s*(.*?)\s*$", line)
        if result:
            is_math = len(result.group(1)) > 0
            key = result.group(2)
            value_str = result.group(3)

            value = get_value(key, value_str, is_math)
            variables[key] = value
            if key == 'Nummer':
                assert(current_nested_object is None)
                current_item = value
                # TODO: "Default-Werte festlegen"
                #assert(current_item not in objects[current_object]['items'].keys())
                objects[current_object]['items'][current_item] = {
                    'nested_objects': {}
                }
                continue

            if current_nested_object is None:
                objects[current_object]['items'][current_item][key] = value
            else:
                objects[current_object]['items'][current_item]['nested_objects'][current_nested_object][key] = value

            continue

        print("Could not parse: " + line)
        raise Exception(line)

json.dump(variables, open(os.path.join(export_folder, 'anno-variables.json'), encoding='utf-8', mode='w'), sort_keys=True, indent=2)
json.dump(objects, open(os.path.join(export_folder, 'anno-objects.json'), encoding='utf-8', mode='w'), sort_keys=True, indent=2)
