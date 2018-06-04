# bash_fun
Just some bash programs to learn bash and use it as a real programming language

* Snake game: just start and play
* Polish notaion calc (like lisp): `echo "(* 3 (+ 1 2))" | bash lispcalc.sh`
* Echo server: simple and line-processing
    ##### simple
    ```bash
    ./echo_simple.sh 3000
    ```
    or...
    ##### processed
    ```bash
    ./echo_processed.sh 3000 "tr 'a-z' 'A-Z'"
    ```
    then connect with `nc localhost 3000` and get your messages back ^_^
* Chat server/client:
    start `./server.sh`, then open some terminals and start `./client.sh VASYA`, `./client.sh PETYA`, etc. Enjoy!

* little snippets of interesting or unexpected bash features
