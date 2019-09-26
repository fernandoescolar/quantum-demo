namespace qsharp
{
    open Microsoft.Quantum.Intrinsic;
    
    operation Teleport (source : Qubit, target : Qubit) : Unit
    {
        using (channel = Qubit())
        {
            Entanglement(channel, target);

            // puerta CNOT
            CNOT(source, channel);

            // operador de Hadamard
            H(source);

            // medida
            let data1 = M(source);
            let data2 = M(channel);

            // trasnformación
            if (data1 == One) { Z(target); }
            if (data2 == One) { X(target); }

            // dejar los qubits a Zero
            Reset(channel);
        }
    }

    operation MakeTeleport(message : Result) : Result
    {
        using ((source, target) = (Qubit(), Qubit())) 
        {
            Set(source, message);

            Teleport(source, target);

            let measurement = M(target);
            ResetAll([source, target]);

            return measurement;
        }
    }
}