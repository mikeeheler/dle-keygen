using System;
using System.Collections.Generic;
using System.IO;
using System.Text;

namespace ConvertRNGTable
{
    public static class Program
    {
        private static readonly string[] _languages = { "js" };

        private static List<uint> _rngTable;

        public static int Main(string[] args)
        {
            if (args.Length == 0
                || Array.Find(_languages, it => it == args[0].ToLowerInvariant()) is null)
            {
                Console.Error.WriteLine("Usage: ConvertRNGTable <lang>");
                Console.Error.WriteLine();
                Console.Error.WriteLine("<lang> is one of: " + String.Join(", ", _languages));
                return 1;
            }

            Encoding.RegisterProvider(CodePagesEncodingProvider.Instance);

            _rngTable = new List<uint>(32768);
            string rngTablePath = Path.Combine("..", "..", "FILES", "RNGTABLE.TXT");
            var rngTableEncoding = Encoding.GetEncoding(437);
            using var reader = new StreamReader(File.OpenRead(rngTablePath), rngTableEncoding);

            string line;
            while ((line = reader.ReadLine()) != null)
            {
                string[] elements = line.Split(' ', StringSplitOptions.RemoveEmptyEntries);
                for (int i = 0; i < elements.Length; ++i)
                {
                    uint value = Convert.ToUInt32(elements[i], 16);
                    _rngTable.Add(value);
                }
            }

            string lang = args[0].ToLowerInvariant();
            if (lang == "js")
                ConvertToJS();

            return 0;
        }

        private static void ConvertToJS()
        {
            Console.WriteLine("var rngTable = [" + String.Join(", ", _rngTable) + "];");
        }
    }
}
