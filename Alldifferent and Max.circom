pragma circom 2.1.8;
include "circomlib/circuits/comparators.circom";

template Sum() {
    signal input in[2];
    signal output sum;
    sum <== in[0] + in[1];
}

template AllDifferent(length) {
    signal input values[length];
    signal output different;

    component comparator[length * (length - 1) / 2];
    component sum[length * (length - 1) / 2 + 1];
    var index = 0;
    sum[0] = Sum();
    sum[0].in[0] <== 0;
    sum[0].in[1] <== 0;

    for (var i = 0; i < length; i++) {
        for (var j = i + 1; j < length; j++) {
            comparator[index] = IsEqual();
            comparator[index].in[0] <== values[i];
            comparator[index].in[1] <== values[j];
            sum[index + 1] = Sum();
            sum[index + 1].in[0] <== sum[index].sum;
            sum[index + 1].in[1] <== comparator[index].out;
            index += 1;
        }
    }
    component helper = IsEqual();
    helper.in[0] <== sum[index].sum;
    helper.in[1] <== 0;
    different <== helper.out;
}

template Store() {
    signal input value;
    signal output stored_value;
    stored_value <== value;
}

template Max(length) {
    signal input values[length];
    signal output max;

    component local_max[length + 1];
    component comparator[length];
    component sum[length];
    local_max[0] = Store();
    local_max[0].value <== values[0];

    for (var i = 1; i < length; i++) {
        comparator[i] = GreaterThan(252);
        comparator[i].in[0] <== values[i];
        comparator[i].in[1] <== local_max[i].stored_value;

        local_max[i + 1] = Store();
        sum[i] = Sum();
        sum[i].in[0] <== values[i] * comparator[i].out;
        sum[i].in[1] <== local_max[i].stored_value * (1 - comparator[i].out);
        local_max[i + 1].value <== sum[i].sum;
    }
    max <== local_max[length].stored_value;
}

template Compare() {
    signal input smaller_1;
    signal input smaller_2;
    signal output smaller;

    component comparator_smaller = LessThan(252);
    comparator_smaller.in[0] <== smaller_1;
    comparator_smaller.in[1] <== smaller_2;
    smaller <== comparator_smaller.out;

    signal input bigger_1;
    signal input bigger_2;
    signal output bigger;

    component comparator_bigger = GreaterThan(252);
    comparator_bigger.in[0] <== bigger_1;
    comparator_bigger.in[1] <== bigger_2;
    bigger <== comparator_bigger.out;

    signal input eq_1;
    signal input eq_2;
    signal output eq;

    component comparator_eq = IsEqual();
    comparator_eq.in[0] <== eq_1;
    comparator_eq.in[1] <== eq_2;
    eq <== comparator_eq.out;

    signal input neq_1;
    signal input neq_2;
    signal output neq;

    component comparator_neq = IsEqual();
    comparator_neq.in[0] <== neq_1;
    comparator_neq.in[1] <== neq_2;
    neq <== 1 - comparator_neq.out;

    var diff_length = 4;
    signal input diff_arr[4];
    signal output diff;

    component comparator_diff = AllDifferent(diff_length);
    for (var i = 0; i < diff_length; i++) {
        comparator_diff.values[i] <== diff_arr[i];
    }
    diff <== comparator_diff.different;

    var max_length = 4;
    signal input max_arr[4];
    signal output max;

    component comparator_max = Max(max_length);
    for (var i = 0; i < max_length; i++) {
        comparator_max.values[i] <== max_arr[i];
    }
    max <== comparator_max.max;
}

component main = Compare();
