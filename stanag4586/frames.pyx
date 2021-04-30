import struct

STRUCT_Q = struct.Struct('>Q')


cdef class BaseSTANAGPayload:
    """
    A base class for STANAG payloads
    """
    def __init__(self, bytearray presence_field, unsigned long timestamp=0):
        self.presence_field = presence_field
        self.timestamp = timestamp

    cpdef bint has_field(self, int i):
        """
        Check if given field is present

        :param i: field index to check
        :return: whether the field is present
        """
        cdef:
            int index = i % 8
            int offset = i // 8
        return bool(self.presence_field[offset] >> index)

    cpdef void set_field(self, int i, bint has):
        """
        Set provided field to be present

        :param i: field index 
        :param has: whether the field is available
        """
        cdef:
            int index = i % 8
            int offset = i // 8
            int ofs = 1 << index
        self.presence_field[offset] |= ofs

    cpdef bytes to_bytes(self):
        """Convert to bytes. Override this."""
        if self.presence_field[0] & 1:
            return self.presence_field + STRUCT_Q.pack(self.timestamp)[5:]
        else:
            return self.presence_field
