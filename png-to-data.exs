defmodule PNGtoGB do
  def doit(filename) do
    File.read!(filename)
    |> decodeit()
    |> extractit()
  end

  def decodeit(bin, acc \\ [])
  def decodeit(<<137,80,78,71,13,10,26,10, rest::binary>>, acc), do: decodeit(rest, acc)
  def decodeit(<<length::32, type::binary-4, data::binary-size(length), crc::32, rest::binary>>, acc) do
    calculated = :erlang.crc32(type <> data)
    if calculated == crc do
      decodeit(rest, [{String.to_atom(type), data} | acc])
    else
      raise "crc check failed: #{calculated} != #{crc}"
    end
  end

  def decodeit(<<>>, acc), do: Enum.reverse(acc)

  def extractit(data) do
    {:IHDR, header_bin} = List.key(data, :IHDR, 0)
    header = decode_header(header_bin)
    data_fields = Enum.filter(data, fn {key, _} -> key == :IDAT end)
  end

  def decode_header(<<width::32, height::32, bit_depth::8, color_type::8, compression_method::8, filter_method::8, interlace_method::8>>) do
    %{
      width: width,
      height: height,
      bit_depth: bit_depth,
      color_type: color_type,
      compression_method: compression_method,
      filter_method: filter_method,
      interlace_method: interlace_method
    }
  end

  def parse_2bpp(filename) do
    File.read!(filename)
    |> do_parse_2bpp
  end

  def do_parse_2bpp(<<pixel::4, rest::binary>>) do
    IO.inspect(pixel, base: :binary)
    do_parse_2bpp(rest)
  end
  def do_parse_2bpp(<<>>), do: :ok
end

# PNGtoGB.doit("surprised-pika-160x144.png")
# |> IO.inspect
PNGtoGB.parse_2bpp("smiley-8x8.2bpp")
