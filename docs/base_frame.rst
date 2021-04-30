Base frame
==========

The basic frame is given by the class:

.. autoclass:: stanag4586.base.BaseDatagram
    :members:

To unserialize STANAG 4586 frames you can use:

.. autofunction:: stanag4586.base.parse_datagrams

The message properties is a bitwise union of the following:

.. autodata:: stanag4586.base.MP_NO_ACK

.. autodata:: stanag4586.base.MP_ACK

.. autodata:: stanag4586.base.MP_STANAG_EDITION_3

.. autodata:: stanag4586.base.MP_NO_CHECKSUM

.. autodata:: stanag4586.base.MP_CHECKSUM_16BIT

.. autodata:: stanag4586.base.MP_CHECKSUM_32BIT

Corresponding constants are :code:`cimport`able, but strip the :code:`MP_`.
