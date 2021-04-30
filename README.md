stanag4586
==========

A Cython library for parsing STANAG4586.
https://camo.githubusercontent.com/0542a3a661ac21c3808b0503accad3e8b2fd4fc0cfe64ff280720741386e9294/68747470733a2f2f72656164746865646f63732e6f72672f70726f6a656374732f736174656c6c612f62616467652f3f76657273696f6e3d6c6174657374

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
