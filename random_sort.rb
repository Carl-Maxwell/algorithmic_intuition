
require_relative "./approximate_shellsort_functions"
require "pry-byebug"

class Array
  attr_accessor :random_iterations

  def coherence
    calculate_coherence(self)
  end

  def random_sort
    original_coherence = calculate_coherence(self)

    return self if original_coherence >= 0.98

    shuffled_arr = dup
    shell_sorted_arr = dup

    # permutation(length) do |a_shuffle|
    #    return a_shuffle if calculate_coherence(a_shuffle) > original_coherence
    # end

    self.random_iterations = 0

    # (Math.log2(self.length)).times do
    #   new_shuffle = shuffle
    #   shuffled_arr = new_shuffle if new_shuffle.coherence < shuffled_arr.coherence
    #   self.random_iterations += 1
    # end

    until shuffled_arr.coherence > original_coherence || shell_sorted_arr.coherence > original_coherence
       shuffled_arr = shuffle

       shell_sorted_arr, _ = shell_sort_block(shell_sorted_arr) do |semi_sorted_arr|
         true
        # #  binding.pry if calculate_coherence(arr) < calculate_coherence(semi_sorted_arr)
        #  arr = semi_sorted_arr if calculate_coherence(arr) < calculate_coherence(semi_sorted_arr)
       end

      #  arr = if shuffled_arr.coherence < shell_sorted_arr.coherence then shuffled_arr else shell_sorted_arr end
    end

    arr = if shuffled_arr.coherence > shell_sorted_arr.coherence then shuffled_arr else shell_sorted_arr end
    arr.random_iterations = self.random_iterations

    arr
  end
end

def run_test(n)
  arr = (1..n).to_a.shuffle

  [arr, arr.random_sort]
end

def run_test_and_describe(n)
  unsorted, sorted = run_test(n)

  coherence_gain = sorted.coherence - unsorted.coherence

  puts unsorted, sorted, "coherence gain: #{coherence_gain}", "iterations: #{sorted.random_iterations}"

  [unsorted, sorted, coherence_gain]
end

def describe_arrays(unsorted, sorted)
  coherence_gain = sorted.coherence - unsorted.coherence

  puts "iterations: #{sorted.random_iterations}", "old coherence: #{unsorted.coherence}", "coherence gain: #{coherence_gain}", unsorted, sorted
end

def test_successive_iteration(n)
  unsorted = (1..n).to_a.shuffle
  sorted   = unsorted.dup

  i_sum = 0

  (n*Math.log2(n)).to_i.times do
    last_sorted = sorted
    sorted = sorted.random_sort
    i_sum += sorted.random_iterations
    describe_arrays(last_sorted, sorted)
  end

  puts
  puts "total iterations: #{i_sum}", "n*log2(n): #{n*Math.log2(n)}"
end

def run_successive_tests(n)
  test_successive_iteration(n)
end

def run_atomic_operation_tests(n)
  gain_sum       = 0.0
  iterations_sum = 0

  n.times do
    _, sorted, coherence_gain = run_test_and_describe(n)

    gain_sum += coherence_gain
    # iterations_sum += sorted.random_iterations
  end

  puts "avg gain: #{gain_sum/n}", "min gain: #{min_incoherence(n)}"#, "avg_iterations: #{iterations_sum/n}"
end

run_successive_tests(10)
