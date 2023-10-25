import sys

hex_sequence = open(sys.argv[1]).readlines()[0].strip()
sequence = bin(int(hex_sequence, 16))[2:].zfill(len(hex_sequence) * 4)


class Packet:
    PACKET_VERSION_SIZE = 3
    PACKET_TYPE_ID_SIZE = 3
    PACKET_HEADER_SIZE = PACKET_VERSION_SIZE + PACKET_TYPE_ID_SIZE
    PACKET_TYPE_LITERAL_VALUE = 4

    def __init__(self, starting_position: int, version: int):
        print(f"Starting to read a {self.__class__.__name__}")
        self.starting_position = starting_position
        self.version = version

    @staticmethod
    def read_binary(from_index: int, size: int) -> int:
        read_content = sequence[from_index:(from_index + size)]
        print(f"Reading {sequence[0:from_index]}[{read_content}]{sequence[from_index + size:]}")
        return int(read_content, 2)

    @staticmethod
    def parse_packet(starting_position: int):
        version = Packet.read_binary(starting_position, Packet.PACKET_VERSION_SIZE)
        type_id = Packet.read_binary(starting_position + Packet.PACKET_VERSION_SIZE, Packet.PACKET_TYPE_ID_SIZE)
        print(f"Starting to read a packet at {starting_position} with version {version} and type {type_id}")
        match type_id:
            case Packet.PACKET_TYPE_LITERAL_VALUE:
                return LiteralValuePacket(starting_position, version)
            case _:
                return OperatorPacket(starting_position, version)


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
        print(f"\tValue is {self.value}")
        print(f"Ending reading LiteralValuePacket, last position is {self.last_position}")

    def total(self) -> int:
        return self.version


class OperatorPacket(Packet):
    SUB_PACKETS_LENGTH_TYPE_SIZE = 1
    SUB_PACKETS_LENGTH_SIZE = 15
    SUB_PACKETS_NUMBER_SIZE = 11

    def __init__(self, starting_position: int, version: int):
        Packet.__init__(self, starting_position, version)
        length_type_id = Packet.read_binary(
            starting_position + Packet.PACKET_HEADER_SIZE,
            OperatorPacket.SUB_PACKETS_LENGTH_TYPE_SIZE)
        print(f"\tLength type is {length_type_id}")
        self.sub_packets = []
        match length_type_id:
            case 0:
                sub_packets_size = Packet.read_binary(
                    starting_position + Packet.PACKET_HEADER_SIZE + OperatorPacket.SUB_PACKETS_LENGTH_TYPE_SIZE,
                    OperatorPacket.SUB_PACKETS_LENGTH_SIZE)
                print(f"Sub-packets size is {sub_packets_size}")
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
                print(f"Sub-packets number is {sub_packets_number}")
                current_sub_packet_position = starting_position + Packet.PACKET_HEADER_SIZE + OperatorPacket.SUB_PACKETS_LENGTH_TYPE_SIZE + OperatorPacket.SUB_PACKETS_NUMBER_SIZE
                for packet_index in range(0, sub_packets_number):
                    sub_packet = Packet.parse_packet(current_sub_packet_position)
                    self.sub_packets.append(sub_packet)
                    current_sub_packet_position = sub_packet.last_position
                self.last_position = self.sub_packets[-1].last_position
            case _:
                raise Exception(length_type_id)
        print(f"Ending reading OperatorPacket, last position is {self.last_position}")

    def total(self) -> int:
        return self.version + sum(map(lambda p: p.total(), self.sub_packets))


main_packet = Packet.parse_packet(0)
print(main_packet.total())
