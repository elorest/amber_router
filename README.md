# amber_router

Added new idea to benchmarks.

```
/get/
 jewel: root   9.83M (101.77ns) (± 2.03%)       fastest
router: root   2.28M (439.33ns) (± 4.55%)  4.32× slower
 radix: root   3.34M (299.32ns) (± 6.37%)  2.94× slower


/get/books/23/chapters
 jewel: deep   1.59M (628.51ns) (± 3.65%)       fastest
router: deep   1.41M (708.02ns) (± 1.74%)  1.13× slower
 radix: deep   1.26M (792.69ns) (± 1.76%)  1.26× slower


/get/books/23/pages
 jewel: wrong   1.01M (992.57ns) (± 1.35%)  1.72× slower
router: wrong   1.74M (576.04ns) (± 2.06%)       fastest
 radix: wrong   1.37M (728.53ns) (± 1.42%)  1.26× slower


/get/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z
 jewel: many segments   1.46M ( 683.3ns) (± 1.17%)  1.23× slower
router: many segments 297.68k (  3.36µs) (± 1.46%)  6.03× slower
 radix: many segments    1.8M (556.81ns) (± 1.65%)       fastest


/get/var/2/3/4/5/6/7/8/9/0/1/2/3/4/5/6/7/8/9/0/1/2/3/4/5/6
 jewel: many variables 694.22k (  1.44µs) (± 0.86%)       fastest
router: many variables 285.49k (   3.5µs) (± 2.10%)  2.43× slower
 radix: many variables 277.24k (  3.61µs) (± 2.70%)  2.50× slower


/get/foobarbizfoobarbizfoobarbizfoobarbizfoobarbizbat/3
 jewel: long_segments 887.61k (  1.13µs) (± 1.30%)  1.77× slower
router: long_segments   1.57M (636.78ns) (± 1.41%)       fastest
 radix: long_segments   1.08M (930.12ns) (± 1.61%)  1.46× slower
```
