import sys

target_filepath = sys.argv[1] # Modified in place
modules_to_remove = sys.argv[2:]

if __name__ == '__main__':
    with open(target_filepath, 'r') as fd:
        lines = fd.readlines()
    for module in modules_to_remove:
        print('Removing module {} from {}'.format(module, target_filepath))
        line_ids_to_remove = []
        found = False
        for line_id, line in enumerate(lines):
            if ' module ' + module in line:
                print('Found module def')
                line_ids_to_remove.append(line_id)
                for next_line_id in range(line_id+1, len(lines)):
                    if ' module ' in lines[next_line_id]:
                        found = True
                        break
                    line_ids_to_remove.append(next_line_id)
                if found:
                    print('Skipping now')

                    break
        for line_id in reversed(line_ids_to_remove):
            lines.pop(line_id)
    with open(target_filepath, 'w') as fd:
        fd.writelines(lines)


