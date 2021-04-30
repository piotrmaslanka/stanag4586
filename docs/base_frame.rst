Base frame
==========

The basic frame is given by the class:

.. autoclass:: stanag4586.base.BaseDatagram
    :members:

To unserialize STANAG 4586 frames you can use:

.. autofunction:: stanag4586.base.parse_datagrams

The message properties is a bitwise union of the following, available only via cimport:

.. code-block:: python

    stanag4586.base.NO_ACK - This is not an ACK message

    stanag4586.base.ACK - This is an ACK response

    stanag4586.base.STANAG_EDITION_3    -    Needs to be on in every datagram

    stanag4586.base.NO_CHECKSUM     -    This datagram will have no checksum

    stanag4586.base.CHECKSUM_16BIT  -   This datagram will have 16-bit checksum

    stanag4586.base.CHECKSUM_32BIT  -   This datagram will have 32-bit checksum

