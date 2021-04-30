import typing as tp
import os

import yaml
from satella.files import write_to_file, read_in_file
from caseconverter import pascalcase

STANAG = 'stanag4586'
DEFS = 'definitions'


def type_to_types(type: str) -> tp.Tuple[str, str]:
    if type.startswith('uint'):
        i = int(type[4:])
        if i == 8:
            return 'unsigned char', 'B'
        elif i == 16:
            return 'unsigned short', 'H'
        elif i == 32:
            return 'unsigned int', 'L'
    elif type.startswith('bitmap'):
        i = int(type[6:])
        if i == 8:
            return 'unsigned char', 'B'
        elif i == 16:
            return 'unsigned short', 'H'
        elif i == 32:
            return 'unsigned int', 'L'
    elif type.startswith('sint'):
        i = int(type[4:])
        if i == 8:
            return 'char', 'b'
        elif i == 16:
            return 'short', 'h'
        elif i == 32:
            return 'int', 'l'


def process_a_module(depo_name: str, module_name: str, module_desc: dict):
    class_name = module_desc.get('class_name', pascalcase(module_name))
    print(class_name)

    pyx_file = open(os.path.join(STANAG, depo_name + '.pyx'), 'a')
    pxd_file = open(os.path.join(STANAG, depo_name + '.pxd'), 'a')
    doc_file = open(os.path.join('docs', depo_name + '.rst'), 'a')
    print(module_desc)

    pxd_parts = [f'\ncdef class {class_name}(BaseSTANAGPayload):\n'
                 f'    cdef:\n']

    for field in module_desc['fields']:
        type = type_to_types(field['type'])[0]
        name = field['name']
        pxd_parts.append(f'        public {type} {name}\n')

    pxd_file.write(''.join(pxd_parts))

    constructor_args = []
    for field in module_desc['fields']:
        type = type_to_types(field['type'])[0]
        name = field['name']
        constructor_args.append(f'{type} {name}')
    constructor_args = ', '.join(constructor_args)

    pyx_args = [f'\ncdef class {class_name}(BaseSTANAGPayload):\n',
                f'    def __init__(self, bytearray presence_field, unsigned long timestamp, {constructor_args}):\n',
                f'        super().__init__(presence_field, timestamp)\n']

    fields = []
    args = []
    for field in module_desc['fields']:
        name = field['name']
        pyx_args.append(f'        self.{name} = {name}\n')
        fields.append(type_to_types(field['type'])[1])
        args.append(f'self.{name}')

    args = ', '.join(args)
    fields = ''.join(fields)
    pyx_args.append(f'\n    cpdef bytes to_bytes(self):\n')
    pyx_args.append(f'        cdef list parts = [super().to_bytes()]\n')

    for i, field in zip(range(1, len(module_desc['fields'])+1), module_desc['fields']):
        btype = type_to_types(field['type'])[1]
        name = field['name']
        pyx_args.append(f'        if self.has_field({i}):\n')
        pyx_args.append(f'            parts.append(STRUCT_{btype}.pack(self.{name}))\n')
    pyx_args.append(f'        return b\'\'.join(parts)\n')


    pyx_args.append(f'\n    cpdef int get_field_count(self):\n')
    len_fields = len(module_desc['fields'])
    pyx_args.append(f'        return super().get_field_count() + {len_fields}\n\n')


    pyx_file.write(''.join(pyx_args))

    docs_args = [f'.. autoclass:: stanag4586.{depo_name}.{class_name}\n'
                 f'    :members:\n']

    doc_file.write(''.join(docs_args))

    pyx_file.close()
    pxd_file.close()
    doc_file.close()


def zeroize(path: str, with_v: str):
    if os.path.exists(path):
        os.unlink(path)
    write_to_file(path, with_v, 'utf-8')


def process_a_file(filename: str):
    module_name = filename[:-len('.stanag')]
    modules = yaml.load(open(os.path.join(DEFS, filename), 'rb'),
                        Loader=yaml.Loader)

    zeroize(os.path.join(STANAG, module_name+'.pyx'), 'from .frames cimport BaseSTANAGPayload\n'
                                                      'import struct\n\n'
                                                      "STRUCT_H = struct.Struct('>H')\n"
                                                      "STRUCT_h = struct.Struct('>h')\n"
                                                      "STRUCT_B = struct.Struct('>B')\n"
                                                      "STRUCT_b = struct.Struct('>b')\n"
                                                      "STRUCT_L = struct.Struct('>I')\n"
                                                      "STRUCT_l = struct.Struct('>i')\n")
    zeroize(os.path.join(STANAG, module_name+'.pxd'), 'from .frames cimport BaseSTANAGPayload\n')
    zeroize(os.path.join('docs', module_name+'.rst'), '')

    for mod_name, module in modules.items():
        process_a_module(module_name, mod_name, module)


if __name__ == '__main__':
    for file in os.listdir(DEFS):
        process_a_file(file)

    definitions = os.listdir(DEFS)
    definitions = ('   '+def_v[:-len('.stanag')] for def_v in definitions)
    definitions = '\n'.join(definitions)
    file = read_in_file(os.path.join('docs', 'index.rst'), 'utf-8')
    file = file.replace('$INDEX', definitions)
    write_to_file(os.path.join('docs', 'index.rst'), file, 'utf-8')
