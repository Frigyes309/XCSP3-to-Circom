pragma circom 2.0.0;
include "circomlib/circuits/comparators.circom";

template Sum() {
    signal input in[2];
    signal output sum;
    sum <== in[0] + in[1];
}

template stateVerifier(N) {
   signal input stateFrom;
   signal input stateTo;
   signal output valid;

   // Reduced possible states to about 10 transitions
   var possibleStates[2][N] = [
       [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
       [2, 3, 4, 5, 6, 7, 8, 9, 10, 1]
   ];

   component isOK[N*2];
   component sum[N + 1];
   sum[0] = Sum();
   sum[0].in[0] <== 0;
   sum[0].in[1] <== 0;
   for (var i = 0; i < N; i++) {
      isOK[i] = IsEqual();
      isOK[i].in[0] <== stateFrom;
      isOK[i].in[1] <== possibleStates[0][i];

      isOK[i+N] = IsEqual();
      isOK[i+N].in[0] <== stateTo;
      isOK[i+N].in[1] <== possibleStates[1][i];

      sum[i + 1] = Sum();
      sum[i + 1].in[0] <== isOK[i].out * isOK[i + N].out;
      sum[i + 1].in[1] <== sum[i].sum;
   }
   valid <== sum[N].sum;
}

template stateChanger(N) {
   signal input stateFrom;
   signal input command;
   signal input stateTo;
   signal output valid;

   var currentCommand = 0;
   component isCommand = IsEqual();
   isCommand.in[0] <== command;
   isCommand.in[1] <== stateTo - stateFrom;
   signal possible <== isCommand.out;

   component verifier = stateVerifier(N);
   verifier.stateFrom <== stateFrom;
   verifier.stateTo <== stateTo;

   valid <== verifier.valid * possible;
}

component main = stateChanger(10);
