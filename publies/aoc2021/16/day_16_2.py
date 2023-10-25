import sys
import functools

hex_sequence = sys.argv[1].strip()
sequence = bin(int(hex_sequence, 16))[2:].zfill(len(hex_sequence) * 4)


class Packet:
    PACKET_VERSION_SIZE = 3
    PACKET_TYPE_ID_SIZE = 3
    PACKET_HEADER_SIZE = PACKET_VERSION_SIZE + PACKET_TYPE_ID_SIZE
    PACKET_TYPES = {}

    def __init__(self, starting_position: int, version: int):
        self.starting_position = starting_position
        self.version = version

    @staticmethod
    def read_binary(from_index: int, size: int) -> int:
        read_content = sequence[from_index:(from_index + size)]
        return int(read_content, 2)

    @staticmethod
    def parse_packet(starting_position: int):
        version = Packet.read_binary(starting_position, Packet.PACKET_VERSION_SIZE)
        type_id = Packet.read_binary(starting_position + Packet.PACKET_VERSION_SIZE, Packet.PACKET_TYPE_ID_SIZE)
        if type_id in Packet.PACKET_TYPES:
            return Packet.PACKET_TYPES[type_id](starting_position, version)
        else:
            raise Exception(type_id)


class LiteralValuePacket(Packet):
    def __init__(self, starting_position: int, version: int):
        Packet.__init__(self, starting_position, version)

        self.last_position = starting_position + Packet.PACKET_HEADER_SIZE
        value_bits = []
        while sequence[self.last_position] == `'1`':
            value_bits.extend(sequence[(self.last_position + 1):(self.last_position + 5)])
            self.last_position += 5
        value_bits.extend(sequence[(self.last_position + 1):(self.last_position + 5)])
        self.value = int(`'`'.join(value_bits), 2)
        self.last_position += 5
        print(self.total())

    def total(self) -> int:
        return self.value


class OperatorPacket(Packet):
    SUB_PACKETS_LENGTH_TYPE_SIZE = 1
    SUB_PACKETS_LENGTH_SIZE = 15
    SUB_PACKETS_NUMBER_SIZE = 11

    def __init__(self, starting_position: int, version: int):
        Packet.__init__(self, starting_position, version)
        length_type_id = Packet.read_binary(
            starting_position + Packet.PACKET_HEADER_SIZE,
            OperatorPacket.SUB_PACKETS_LENGTH_TYPE_SIZE)
        self.sub_packets = []
        match length_type_id:
            case 0:
                sub_packets_size = Packet.read_binary(
                    starting_position + Packet.PACKET_HEADER_SIZE + OperatorPacket.SUB_PACKETS_LENGTH_TYPE_SIZE,
                    OperatorPacket.SUB_PACKETS_LENGTH_SIZE)
                current_sub_packet_position = starting_position + Packet.PACKET_HEADER_SIZE + OperatorPacket.SUB_PACKETS_LENGTH_TYPE_SIZE + OperatorPacket.SUB_PACKETS_LENGTH_SIZE
                self.last_position = current_sub_packet_position + sub_packets_size
                while current_sub_packet_position < self.last_position:
                    sub_packet = Packet.parse_packet(current_sub_packet_position)
                    self.sub_packets.append(sub_packet)
                    current_sub_packet_position = sub_packet.last_position
            case 1:
                sub_packets_number = Packet.read_binary(
                    starting_position + Packet.PACKET_HEADER_SIZE + OperatorPacket.SUB_PACKETS_LENGTH_TYPE_SIZE,
                    OperatorPacket.SUB_PACKETS_NUMBER_SIZE)
                current_sub_packet_position = starting_position + Packet.PACKET_HEADER_SIZE + OperatorPacket.SUB_PACKETS_LENGTH_TYPE_SIZE + OperatorPacket.SUB_PACKETS_NUMBER_SIZE
                for packet_index in range(0, sub_packets_number):
                    sub_packet = Packet.parse_packet(current_sub_packet_position)
                    self.sub_packets.append(sub_packet)
                    current_sub_packet_position = sub_packet.last_position
                self.last_position = self.sub_packets[-1].last_position
            case _:
                raise Exception(length_type_id)

    def total(self) -> int:
        return self.version + sum(map(lambda p: p.total(), self.sub_packets))

    def sub_packets_values(self) -> map:
        return map(lambda p: p.total(), self.sub_packets)


class SumPacket(OperatorPacket):
    def total(self) -> int:
        return sum(self.sub_packets_values())


class ProductPacket(OperatorPacket):
    def total(self) -> int:
        return functools.reduce(lambda a, b: a * b, self.sub_packets_values())


class MinimumPacket(OperatorPacket):
    def total(self) -> int:
        return min(self.sub_packets_values())


class MaximumPacket(OperatorPacket):
    def total(self) -> int:
        return max(self.sub_packets_values())


class TestPacket(OperatorPacket):
    def sub_packets_values(self):
        if len(self.sub_packets) != 2:
            raise Exception(self.sub_packets)
        return self.sub_packets[0].total(), self.sub_packets[1].total()


class GreaterThanPacket(TestPacket):
    def total(self) -> int:
        sub_packet_1_value, sub_packet_2_value = self.sub_packets_values()
        return 1 if sub_packet_1_value > sub_packet_2_value else 0


class LessThanPacket(TestPacket):
    def total(self) -> int:
        sub_packet_1_value, sub_packet_2_value = self.sub_packets_values()
        return 1 if sub_packet_1_value < sub_packet_2_value else 0


class EqualToPacket(TestPacket):
    def total(self) -> int:
        sub_packet_1_value, sub_packet_2_value = self.sub_packets_values()
        return 1 if sub_packet_1_value == sub_packet_2_value else 0


Packet.PACKET_TYPES[0] = SumPacket
Packet.PACKET_TYPES[1] = ProductPacket
Packet.PACKET_TYPES[2] = MinimumPacket
Packet.PACKET_TYPES[3] = MaximumPacket
Packet.PACKET_TYPES[4] = LiteralValuePacket
Packet.PACKET_TYPES[5] = GreaterThanPacket
Packet.PACKET_TYPES[6] = LessThanPacket
Packet.PACKET_TYPES[7] = EqualToPacket

main_packet = Packet.parse_packet(0)
print(main_packet.total())
