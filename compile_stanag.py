import os

import yaml
from satella.files import write_to_file, read_in_file
from caseconverter import pascalcase

STANAG = 'stanag4586'


def process_a_module(depo_name: str, module_name: str, module_desc: dict):
    class_name = module_desc.get('class_name', pascalcase(module_name))
    print(class_name)

    pyx_file = open(os.path.join(STANAG, depo_name + '.pyx'), 'a')
    pxd_file = open(os.path.join(STANAG, depo_name + '.pxd'), 'a')
    doc_file = open(os.path.join('docs', depo_name + '.rst'), 'a')
    print(module_desc)

    pyx_file.close()
    pxd_file.close()
    doc_file.close()


def zeroize(path: str, with_v: str):
    if os.path.exists(path):
        os.unlink(path)
    write_to_file(path, with_v, 'utf-8')


def process_a_file(filename: str):
    module_name = filename[:-len('.stanag')]
    modules = yaml.load(open(os.path.join('definitions', filename), 'rb'),
                        Loader=yaml.Loader)

    zeroize(os.path.join(STANAG, module_name+'.pyx'), 'from .frames cimport BaseSTANAGPayload\n')
    zeroize(os.path.join(STANAG, module_name+'.pxd'), 'from .frames cimport BaseSTANAGPayload\n')
    zeroize(os.path.join('docs', module_name+'.rst'), '')

    for mod_name, module in modules.items():
        process_a_module(module_name, mod_name, module)


if __name__ == '__main__':
    for file in os.listdir('definitions'):
        process_a_file(file)

    definitions = os.listdir('definitions')
    definitions = ('   '+def_v[:-len('.stanag')] for def_v in definitions)
    definitions = '\n'.join(definitions)
    file = read_in_file(os.path.join('docs', 'index.rst'), 'utf-8')
    file = file.replace('$INDEX', definitions)
    write_to_file(os.path.join('docs', 'index.rst'), file, 'utf-8')
