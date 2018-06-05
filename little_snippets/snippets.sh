### quotes magic
a='*'

echo $a
echo '$a'
echo "$a"

### stream multiplexing 
cat | tee >(grep foo | wc -l > foo.count)\
          >(grep baz | wc -l > baz.count)\
          |(grep egg | wc -l > egg.count)
