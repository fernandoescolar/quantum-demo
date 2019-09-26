using System;
using Microsoft.Quantum.Simulation.Simulators;
using System.Collections.Generic;

namespace qsharp
{
    class Program
    {
        static void Main(string[] args)
        {
            bool exit = false;
            do {
                var option = Menu();
                exit = Run(option);
            } while(!exit);
            
        }

        private static int Menu()
        {
            Console.Clear();
            Console.WriteLine("Welcome to Quantum Programming demo");
            Console.WriteLine("Copyrigth (c) 2019\n");
            Console.WriteLine("Subroutines:");
            Console.WriteLine();
            Console.WriteLine("0. Set");
            Console.WriteLine("1. Measure");
            Console.WriteLine("2. CNOT");
            Console.WriteLine("3. SWAP");
            Console.WriteLine("4. Entanglement");
            Console.WriteLine("5. Teleport");
            Console.WriteLine("6. Shor");
            Console.WriteLine("7. Exit");

            var result = Console.ReadLine();
            if (int.TryParse(result, out var i) && i >= 0 && i <= 7) return i;
            return Menu();
        }

        private static bool Run(int option)
        {
            if (option >= Actions.Count || option < 0) return true;
            using (var qsim = new QuantumSimulator())
            {
                Console.WriteLine();
                Actions[option].Run(qsim);
            }
            
            Console.ReadLine();
            return false;
        }

        private static readonly List<IDriver> Actions = new List<IDriver>
        {
            new SetDriver(),
            new MeasureDriver(),
            new CNOTDriver(),
            new SWAPDriver(),
            new EntanglementDriver(),
            new TeleportDriver(),
            new ShorDriver()
        };
    }
}