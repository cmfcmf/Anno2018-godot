extends "res://test/base_test.gd"

var cp = null

var cod_path = base_path + "/cod.cod"
var cod_txt_path = base_path + "/cod.cod.txt"
var cod_json_path = base_path + "/cod.json"

func setup():
	.setup()
	cp = preload("res://parser/cod_parser.gd").new()

func test_cod_to_txt():
	dump_file(cod_path, PoolByteArray([
		0xd3, 0xd3, 0xd3, 0xd3, 0xd3, 0xd3, 0xd3, 0xd3, 0xd3, 0xd3, 0xd3, 
		0xd3, 0xd3, 0xd3, 0xd3, 0xd3, 0xd3, 0xd3, 0xf3, 0xf6, 0xa5, 0xb9, 
		0xbf, 0xb3, 0xbb, 0xa3, 0xf3, 0xf6, 0xb4, 0x9f, 0x99, 0x9b, 0x8e, 
		0xc6, 0xe0, 0xf3, 0xf6, 0x94, 0x9b, 0x9b, 0x8e, 0x94, 0x9b, 0x9b, 
		0x8e, 0x94, 0x9b, 0x9b, 0x8e, 0xe0, 0xf3, 0xf6, 0xdb, 0x9c, 0xdb, 
		0xdb, 0xe0, 0xad, 0x8c, 0x9b, 0x8b, 0x9b, 0x8e, 0xc6, 0xf3, 0xf6,
	]))
	cp.cod_to_txt(cod_path, cod_txt_path)
	assert_file_content(cod_txt_path, """------------------
[GAME]
Lager: 
leerleerleer 
%d%% Steuer:
""")

func test_cod_txt_to_json_comments_and_constants():
	assert_cod_txt_to_json("""

; This is a comment
;======;

;;;  ;;; ;$% ;&/%; %;§; ;/ ; /&

  	IDSTRAND     =    100
		GFXBODEN   =    300
  GFXHANG   =     GFXBODEN+500

   Nahrung:    1.3

KOST_BEDARF_3_SLP = 38

  ; Another comment
""", {
		'objects': {},
		'variables': {
			'IDSTRAND': 100,
			'GFXBODEN': 300,
			'GFXHANG': 800,
			# TODO: Nahrung
			'KOST_BEDARF_3_SLP': 38,
		},
	})
	
func test_cod_txt_to_json_objects():
	assert_cod_txt_to_json("""
  Objekt: BGRUPPE

    Nummer:     0
    Maxwohn:    2              ; A comment
    Steuer:     1.4            ; Another comment

    Nummer:     1
    Maxwohn:    6
    Steuer:     1.6
    Objekt:     BGRUPPE_WARE
	  Foo: bar
      Ware:       STOFFE, 0.6       ; ORG/SUN  1.0 / 0.4
      Ware:       ALKOHOL, 0.5      ; ORG/SUN  0.8 / 0.4

    EndObj;""", {
		'variables': {
			"Foo":"bar",
			"Maxwohn": 6,
			"Nummer": 1,
			"Steuer":1.6, 
			"Ware": {"ALKOHOL": 0.5}
		},
		'objects': {
			'BGRUPPE': {
				'items': {
					'0': {
						"Maxwohn": 2,
						"Steuer": 1.4,
						"nested_objects": {},
					},
					'1': {
						"Maxwohn": 6,
						"Steuer": 1.6,
						"nested_objects": {
							'BGRUPPE_WARE': {
								'Foo': 'bar',
								'Ware': {
									'STOFFE': 0.6,
									'ALKOHOL': 0.5,
								},
							},
						},
					},
				},
			},
		},
	})

func test_cod_txt_to_json_at_sign():
	assert_cod_txt_to_json("""
Objekt: HELLO
	IDSTART = 42

	@Nummer:    0
	Id:         IDSTART+0

	@Nummer:    +1
	@Id:        +1

	@Nummer:    +1
	VARIABLE = Nummer
	@Id:        +1
EndObj;""", {
		'variables': {
			"IDSTART": 42,
			"VARIABLE": 2,
			"Id": 44,
			"Nummer": 2,
		},
		'objects': {
			'HELLO': {
				'items': {
					'0': {"Id": 42, "nested_objects": {}},
					'1': {"Id": 43, "nested_objects": {}},
					'2': {"Id": 44, "nested_objects": {}},
				},
			},
		},
	})

func test_cod_txt_to_json_size():
	assert_cod_txt_to_json("""
Objekt: HELLO
	Nummer:    1
	Id:        1
	Size:      2, 3
EndObj;""", {
		'variables': {
			"Nummer": 1,
			"Id": 1,
			"Size": {"x": 2, "y": 3}
		},
		'objects': {
			'HELLO': {
				'items': {
					'1': {"Id": 1, "Size": {"x": 2, "y": 3}, "nested_objects": {}},
				},
			},
		},
	})

func test_cod_txt_to_json_objfill():
	assert_cod_txt_to_json("""
Objekt: HELLO
	@Nummer:    0
	NUMMERBASE = Nummer
	A:          5
	B:          6
	Id:         10

	@Nummer:    +1
	ObjFill:    NUMMERBASE
	@Id:        +1

	@Nummer:    +1
	ObjFill:    NUMMERBASE
	@Id:        +1
	A:          7

	@Nummer:    +1
	ObjFill:    NUMMERBASE
	@Id:        +1
	
EndObj;""", {
		'variables': {
			"NUMMERBASE": 0,
			"Id": 13,
			"Nummer": 3,
			"A": 7,
			"B": 6,
		},
		'objects': {
			'HELLO': {
				'items': {
					'0': {"Id": 10, "A": 5, "B": 6, "nested_objects": {}},
					'1': {"Id": 11, "A": 5, "B": 6, "nested_objects": {}},
					'2': {"Id": 12, "A": 7, "B": 6, "nested_objects": {}},
					'3': {"Id": 13, "A": 5, "B": 6, "nested_objects": {}},
				},
			},
		},
	})

func test_cod_txt_to_json_objfill_max():
	assert_cod_txt_to_json("""
Objekt: HELLO
	@Nummer:    0
	A:          5
	Id:         10
	Size:       1, 1
    ObjFill:    0,MAXHELLO

	@Nummer:    +1
	NUMMERBASE = Nummer
	B:          6
	@Id:        +1

	@Nummer:    +1
	ObjFill:    NUMMERBASE
	@Id:        +1
	A:          7
	Size:       2, 3

	@Nummer:    +1
	ObjFill:    NUMMERBASE
	@Id:        +1
	
EndObj;""", {
		'variables': {
			"NUMMERBASE": 1,
			"Id": 13,
			"Nummer": 3,
			"A": 7,
			"B": 6,
			"Size": {"x": 2, "y": 3},
		},
		'objects': {
			'HELLO': {
				'items': {
					'0': {"Id": 10, "A": 5,         "Size": {"x": 1, "y": 1}, "nested_objects": {}},
					'1': {"Id": 11, "A": 5, "B": 6, "Size": {"x": 1, "y": 1}, "nested_objects": {}},
					'2': {"Id": 12, "A": 7, "B": 6, "Size": {"x": 2, "y": 3}, "nested_objects": {}},
					'3': {"Id": 13, "A": 5, "B": 6, "Size": {"x": 1, "y": 1}, "nested_objects": {}},
				},
			},
		},
	})

func assert_cod_txt_to_json(input, output):
	dump_file(cod_txt_path, input)
	cp.txt_to_json(cod_txt_path, cod_json_path)
	assert_json_content(cod_json_path, output)
