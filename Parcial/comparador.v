module comparador(
    input A,
    input B,
    output I,
    output MA,
    output MB
);

assign MA = (A & ~B);
assign I = (~A & ~B)|(A & B);
assign MB = (~A & B);

endmodule