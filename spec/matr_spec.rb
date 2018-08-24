TEST_FILE_DIR = File.join __dir__, "test_files"
FATAL_ERROR   = StandardError

def infile fname
  File.join TEST_FILE_DIR, fname
end

RSpec.describe Matr do
  it "has a version number" do
    expect(Matr::VERSION).not_to be nil
  end


  describe "::main" do
    context "things that raise errors" do
      it "raises error with mismatched scores" do
        fname = "score_mismatch.txt"

        expect { Matr.main infile: infile(fname) }.to raise_error FATAL_ERROR
      end

      context "--ensure-symmetry" do
        it "raises error with non-symmetric input" do
          fname = "not_symmetric.txt"
          opts = {
            infile: infile(fname),
            ensure_symmetry: true
          }

          expect { Matr.main opts }.to raise_error FATAL_ERROR
        end

        it "adds in self hits and reverse hits symmetrically" do
          fname = "adds_self_and_rev_hits.txt"
          expected = File.read(infile(fname) + ".expected")

          opts = {
            infile: infile(fname),
            ensure_symmetry: true,
            self_score: 100
          }

          expect { Matr.main opts }.to output(expected).to_stdout
        end
      end

=begin
      context "--no-ensure-symmetry" do
        it "doesn't raise error with non-symmetric input" do
          fname = "not_symmetric.txt"
          expected = File.read(infile(fname) + ".expected")

          opts = {
            infile: infile(fname),
            ensure_symmetry: false
          }

          expect { Matr.main opts }.to output(expected).to_stdout
        end

        it "adds in self hits and reverse hits (defualt self hit value)" do
          fname = "adds_self_and_rev_hits.txt"
          expected = File.read(infile(fname) + ".no_sym.expected")

          opts = {
            infile: infile(fname),
            ensure_symmetry: false,
            self_score: 100,
            missing_score: 0
          }

          expect { Matr.main opts }.to output(expected).to_stdout
        end
      end
    end
=end

    end

    context "--ensure-self-scores" do
      it "replaces self scores with specified value" do
        fname = "wrong_self_score.txt"
        expected = File.read(infile(fname) + ".expected")

        opts = {
          infile:             infile(fname),
          self_scores:        100,
          ensure_self_scores: true
        }

        expect { Matr.main opts }.to output(expected).to_stdout
      end
    end

    context "--no-ensure-self-scores" do
      it "leaves self scores that don't match" do
        fname = "wrong_self_score.txt"
        expected = File.read(infile(fname) + ".no_fix.expected")

        opts = {
          infile:             infile(fname),
          self_scores:        100,
          ensure_self_scores: false
        }

        expect { Matr.main opts }.to output(expected).to_stdout
      end
    end

    it "checks for duplicates with case sensitivity" do
      fname = "case_sensitive.txt"

      expect { Matr.main infile: infile(fname) }.not_to raise_error
    end
  end
end
