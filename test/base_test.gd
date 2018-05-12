extends "res://addons/gut/test.gd"

const base_path = "res://test/tmp"

func setup():
	gut.directory_delete_files(base_path)
	var temp_dir = Directory.new()
	temp_dir.open(base_path)
	temp_dir.make_dir_recursive(base_path)

func dump_file(path, content):
	if not path.begins_with('res://'):
		path = base_path + '/' + path

	var file = File.new()
	assert_eq(file.open(path, File.WRITE), OK)
	if typeof(content) == TYPE_RAW_ARRAY:
		file.store_buffer(content)
	else:
		file.store_string(content)
	file.close()

func assert_json_content(file_path, object):
	var file = File.new()
	assert_eq(file.open(file_path, File.READ), OK)
	var parse_result = JSON.parse(file.get_as_text())
	assert_eq(parse_result.error, OK)
	var result = parse_result.result
	assert_eq(JSON.print(result, "", true), JSON.print(object, "", true))

func assert_file_content(file_path, content):
	var file = File.new()
	assert_eq(file.open(file_path, File.READ), OK)
	assert_eq(file.get_as_text(), content)
	file.close()