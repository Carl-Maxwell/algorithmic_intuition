
# require "byebug"
# require "pry-byebug"

def shell_sort(a, accuracy = nil)
  iter = 0

  n = a.length

  h = 1 # increment factor

  while (h < n / 3)
      h = (3*h) + 1
  end

  while h >= 1
    for i in h...n
      j = i

      iter += 1 unless a[j] < a[j-h]

      while j >= h && a[j] < a[j-h]
        iter += 1

        if a[j-h] > a[j]
          a[j], a[j-h] = a[j-h], a[j]
        end
        j -= h

        closeness = coherence(a) if accuracy

        if accuracy && closeness > accuracy
          return [a, iter]
        end
      end
    end
    h /= 3
  end

  [a, iter]
end

$coherence_iter = 0

# TODO approximate coherence?

def coherence(elems, max_incoherence = nil)
  1.0 - calculate_incoherence(elems)
end

def calculate_incoherence(elems, max_incoherence = nil)
  max_incoherence = calculate_max_incoherence(elems.length) unless max_incoherence

  sum = elems.each_with_index.reduce(0) do |sum, (elem, i)|
    next sum if i > elems.length - 2

    sum + [0, (elem - elems[i+1]).abs - 1].max
  end
  # output = (sum.to_f / elems.length)

  sum.to_f / max_incoherence
end

def calculate_approximate_coherence(elems, buggy = false)

  max_incoherence = calculate_max_incoherence(elems.length)

  n = elems.length

  sample = (0...n-1).to_a.sample(Math.sqrt(n)*2)

  puts sample if buggy

  # this particular set of sample elements causes problems
  # I think they are too incoherent
  # I think [4, 5] might be the only coherent pair
  # these are the sample elements:
  # [[20, 39],
  # [73, 83],
  # [86, 37],
  # [35, 70],
  # [15, 6],
  # [1, 32],
  # [44, 33],
  # [30, 84],
  # [14, 86],
  # [43, 30],
  # [79, 23],
  # [58, 75],
  # [75, 8],
  # [49, 56],
  # [55, 14],
  # [4, 5],
  # [19, 82],
  # [60, 13]]

  sum = sample.reduce(0) do |sum, i|
    sum + [0, (elems[i] - elems[i+1]).abs - 1].max
  end
  # output = (sum.to_f / elems.length)

  # sum * Math.sqrt(n)

  sum = 1 - (sum * Math.sqrt(n)) / max_incoherence

  if sum < 0.0
    puts elems
    puts sum
    puts "actual coherence: #{coherence(elems)}"
    exit
  end

  sum
end




def puts(*str)
  str << "\n"
  things = str.reduce("") do |sum, elem|
    (unless sum.empty? then sum + ", " else "" end) + elem.to_s
  end

  print things
end

# TODO memoize
# min_incoherence is always = 0
$max_coherence_memo = {}

def calculate_max_incoherence(n)
  return 0 if n < 3
  return 1 if n == 3
  return $max_coherence_memo[n] if $max_coherence_memo.include?(n)

  (n / 2 - 1) * 2 + 1 + calculate_max_incoherence(n-1)
end


def min_incoherence_array(n)
  elems = (1..n).to_a
  elems[-2], elems[-1] = elems[-1], elems[-2]

  elems
end

def min_incoherence(n)
  calculate_incoherence(min_incoherence_array(n))
end

def min_coherence(n)
  coherence(min_incoherence_array(n))
end


def calculate_mini_incoherence

end

results = []

# [0.9, nil].each do |accuracy|
  # (10..1000).each do |n|
  # 1000.times do
    n = 90
    a = (1..n).to_a.shuffle

    $coherence_iter = 0
    initial_coherence = coherence(a)
    # $coherence_iter = 0

  # predicting incoherence:
  # 1.0 / x where x is:
  # [nil, nil, nil, 4, 7, 12, 17, 23, 31, 40, 49, 60, 49, 60, 71, 84, 97, 112, 127, 144, 161, 180, 199, 220] {80: 3120, 81: 3199, 82: 3280, 83: 3361}
  # [nil, nil, nil, nil, 3, 5, 5, 6, 8, 9, 9, 11, 11, 13, 15, 15, 17, 17, 19, 19, 21] {81: 79, 82: 81, 83: 81}
  # [nil, nil, nil, nil, nil, 2, 0, 1, 2, 2, 1, 0, 0, 2, 0, 2, 0, 2, 0, 2] {82: 2, 83: 0}
  # note that n=1 and n=2 are coherence 1.0 by definition not by calculation. n=3 is the first one where incoherence can be measured, and at n= 3 the only possible incoherences are 0.0 and 1.0.

  # TODO write a function for calculating min_incoherence

  def calculate_min_incoherence_part(x)
    if x > 10
      y = x - 10

      # [(y % 2 * 2), (y-1), 9]
      (y % 2 * 2)
    else
      [0, 0, 0, 0, 3, 2, 0, 1, 2, 1, 0][x]
    end
  end

  def calculate_min_incoherence(x)
    (0..x).each.with_index.reduce(0) do |sum, (_, y)|
      sum + calculate_min_incoherence_part(y)
    end
  end

  sequence = (0...20).to_a.map {|x| calculate_min_incoherence(x)}

  puts "calculated sequence: ", sequence

  puts "correct sequence: ", [nil, nil, nil, nil, 3, 5, 5, 6, 8, 9, 9, 11, 11, 13, 15, 15, 17, 17, 19, 19, 21]

    bad_array = [[20, 39],
    [73, 83],
    [86, 37],
    [35, 70],
    [15, 6],
    [1, 32],
    [44, 33],
    [30, 84],
    [14, 86],
    [43, 30],
    [79, 23],
    [58, 75],
    [75, 8],
    [49, 56],
    [55, 14],
    [4, 5],
    [19, 82],
    [60, 13]]

    puts calculate_max_incoherence(n)/n

    puts bad_array.map {|bad| (bad[0] - bad[1]).abs }

    # TODO getting negative numbers from approx, that should be impossible

    # a1, i1 = shell_sort(a.dup, nil)
    # a2, i2 = shell_sort(a.dup, 0.9)

    # TODO find out how close numbers are to their actual destination (litmus test for whether coherence actually works)

    # runs in 2.12 seconds  without coherence


    # if approx_coherence < 0
    #   result = {n: n, approx: approx_coherence, coherence: initial_coherence, accuracy: approx_coherence/initial_coherence}

    #   puts a
    #   puts result

    #   calculate_approximate_coherence(a)

    #   exit
    # end

    # results << {n: n, approx: approx_coherence, coherence: initial_coherence, accuracy: approx_coherence/initial_coherence}

  # end
# end

# results = results.sort_by {|result| result[:accuracy] }

# puts "lowest accuracy", results.first
# puts "highest accuracy", results.last
# puts "average accuracy", results.map {|result| result[:accuracy] }.reduce(&:+).to_f/results.length

# [3, Math.log(a.length), Math.log(a.length)**2, Math.sqrt(a.length), a.length/2, 346/2, nil].each do |sample_size|
#   puts
#   sorted_a = shell_sort(a, sample_size)
#   puts sorted_a
#   puts "coherence", coherence(sorted_a)
# end
