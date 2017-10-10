
require_relative "./approximate_shellsort_functions"
require "pry-byebug"

class Array
  attr_accessor :iterations, :random_gain

  def coherence
    calculate_coherence(self)
  end

  def incoherence
    calculate_incoherence(self)
  end

  def measured_sort
    original_coherence = calculate_coherence(self)

    return self if original_coherence >= 0.98

    shell_sorted_arr = shell_sort do |semi_sorted_arr|
        semi_sorted_arr.coherence > self.coherence
    end

    if incoherence > 0.5
      shuffled_arr = random_sort

      arr = if shuffled_arr.coherence > shell_sorted_arr.coherence then shuffled_arr else shell_sorted_arr end

      arr.iterations = shuffled_arr.iterations + shell_sorted_arr.iterations
      arr.random_gain = shuffled_arr.coherence - shell_sorted_arr.coherence
    else
      arr = shell_sorted_arr

      arr.iterations  = shell_sorted_arr.iterations
      arr.random_gain = 0
    end

    arr
  end

  def shell_sort(&block)
    arr = dup

    self.iterations = 0

    arr, _ = shell_sort_until(arr) do |semi_sorted_arr|
      self.iterations += 1

      if block
        block.call(semi_sorted_arr)
      else
        false
      end
    end

    arr.iterations = self.iterations

    arr
  end

  def random_sort
    arr = dup

    self.iterations = 0

    (Math.log2(self.length)).to_i.times do
      new_shuffle = shuffle
      arr = new_shuffle if new_shuffle.coherence > arr.coherence
      self.iterations += 1
    end

    arr.iterations = self.iterations

    arr
  end

  def permutation_sort
    # permutation(length) do |new_shuffle|
    #   self.iterations += 1
    #   shuffled_arr = new_shuffle if new_shuffle.coherence > original_coherence
    #   break if iterations > (Math.log2(self.length))
    # end
  end
end

def run_test(n)
  arr = (1..n).to_a.shuffle

  [arr, arr.random_sort]
end

def run_test_and_describe(n)
  unsorted, sorted = run_test(n)

  coherence_gain = sorted.coherence - unsorted.coherence

  puts unsorted, sorted, "coherence gain: #{coherence_gain}", "iterations: #{sorted.iterations}"

  [unsorted, sorted, coherence_gain]
end

def describe_arrays(unsorted, sorted)
  coherence_gain = sorted.coherence - unsorted.coherence

  puts "iterations: #{sorted.iterations}", "old incoherence: #{unsorted.incoherence}", "coherence gain: #{coherence_gain}", "random gain: #{sorted.random_gain}"#, unsorted, sorted
end

def test_successive_iteration(n)
  unsorted = (1..n).to_a.shuffle
  sorted   = unsorted.dup

  i_sum             = 0
  total_random_gain = 0.0

  (n*Math.log2(n)).to_i.times do
    last_sorted = sorted
    sorted      = sorted.measured_sort

    i_sum             += sorted.iterations
    total_random_gain += sorted.random_gain

    # describe_arrays(last_sorted, sorted) if sorted.random_gain > 0

    break if sorted.coherence >= 0.97
  end

  shell_sorted = unsorted.dup.shell_sort

  # puts "initial incoherence: #{unsorted.incoherence}", "total iterations: #{i_sum} (#{(i_sum.to_f/shell_sorted.iterations - 1.0)*100}% gained)", "| straight shell sort iterations: #{shell_sorted.iterations}", "| n*log2(n): #{n*Math.log2(n)}"
  # puts "initial incoherence: #{unsorted.incoherence - 0.5}", "iteration gain: (#{(i_sum.to_f/shell_sorted.iterations - 1.0)*100}% gained)"
  [unsorted.incoherence - 0.5, (i_sum.to_f/shell_sorted.iterations - 1.0)*100]
end

def run_successive_tests(n)
  results = []
  100.times do
    disorder, iteration_gain = test_successive_iteration(n)

    results << {disorder: disorder, iteration_gain: iteration_gain}
  end

  results = results.sort_by {|result| result[:disorder] }

  results.each {|result| puts result[:iteration_gain] }
end

def run_atomic_operation_tests(n)
  gain_sum       = 0.0
  iterations_sum = 0

  n.times do
    _, sorted, coherence_gain = run_test_and_describe(n)

    gain_sum       += coherence_gain
    iterations_sum += sorted.iterations
  end

  puts "avg gain: #{gain_sum/n}", "min gain: #{min_incoherence(n)}", "avg_iterations: #{iterations_sum/n}"
end

run_successive_tests(100)
