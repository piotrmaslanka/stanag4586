import struct

STANAG_FRAME = struct.Struct('>HHLLHH')
STRUCT_H = struct.Struct('>H')
STRUCT_L = struct.Struct('>L')


cdef inline unsigned long checksum(bytes b, int checksum_length):
    cdef:
        unsigned long modulo
        unsigned long counter = 0
        int byte
    if checksum_length == 2:
        modulo = 2**16
    elif checksum_length == 4:
        modulo = 2**32
    else:
        modulo = 1

    for byte in b:
        counter += byte % modulo
    return counter


cdef class BaseDatagram:
    """
    A base STANAG 4586 frame
    """
    def __init__(self, bytes payload, unsigned int sequence_no,
                 unsigned int source_id, unsigned int destination_id,
                 unsigned short message_type, unsigned short message_properties):
        self.payload = payload
        self.sequence_no = sequence_no
        self.source_id = source_id
        self.destination_id = destination_id
        self.message_type = message_type
        self.message_properties = message_properties

    def __bytes__(self):
        return self.to_bytes()

    cpdef int checksum_length(self):
        """Return checksum length"""
        return ((self.message_properties >> 6) & 3) << 1

    cpdef bytes get_body(self):
        """
        Return the message without the checksum
        """
        data = STANAG_FRAME.pack(self.sequence_no, len(self.payload),
                                 self.source_id, self.destination_id,
                                 self.message_type, self.message_properties) + self.payload
        return data + self.payload

    def __len__(self):
        return STANAG_FRAME.calcsize() + len(self.payload) + self.checksum_length()

    cpdef bytes to_bytes(self):
        """
        Convert the message to bytes
        """
        cdef:
            bytes body = self.get_body()
            int checksum_length = self.checksum_length()

        if checksum_length == 0:
            return body

        cdef unsigned long check_sum = checksum(body, checksum_length)

        if checksum_length == 2:
            return body + STRUCT_H.pack(check_sum)
        elif checksum_length == 4:
            return body + STRUCT_L.pack(check_sum)

