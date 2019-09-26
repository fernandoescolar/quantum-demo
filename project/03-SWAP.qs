namespace qsharp
{
    open Microsoft.Quantum.Intrinsic;

    operation MakeSWAP(control: Result, target: Result): (Result, Result)
    {
        using (qubits = Qubit[2])
        {
            Set(qubits[0], control);
            Set(qubits[1], target);

            SWAP(qubits[0], qubits[1]);

            let resControl = M(qubits[0]);
            let resTarget = M(qubits[1]);

            ResetAll(qubits);

            return (resControl, resTarget);
        }
    }
}