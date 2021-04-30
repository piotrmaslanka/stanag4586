stanag4586
==========

A Cython library for parsing STANAG4586.

Installation
------------

You can use the module in two ways:

Plain Python installation:

```bash
wget https://git.cervirobotics.com/api/v4/projects/227/jobs/artifacts/master/download?job=build
unzip artifacts.zip
pip install stanag*.whl
```

And additionally in order to use the headers please do:

```bash
git clone https://git.cervirobotics.com/pmaslanka/stanag4586.git
mv stanag4586 stanag4586.bak
mv stanag4586.bak/stanag4586 stanag4586
rm -rf stanag4586.bak
```
