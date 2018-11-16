TEST_FILE_DIR = File.join __dir__, "test_files"
FATAL_ERROR   = StandardError

def infile fname
  File.join TEST_FILE_DIR, fname
end

def full_path fname
  File.join TEST_FILE_DIR, "all_combinations", fname
end


def make_opts infile, mode, ensure_self_scores, na_replace = nil, output_style = "wide"
  opts = {
    infile:             infile,
    mode:               mode,
    self_score:         100,
    ensure_self_scores: ensure_self_scores,

    # This is how optimist will pass in args.
    na_replace:       na_replace ? na_replace : nil,
    na_replace_given: na_replace ? true : nil,
    output_style:     output_style
  }

  opts
end

RSpec.describe Matr do
  it "has a version number" do
    expect(Matr::VERSION).not_to be nil
  end


  describe "::main" do
    shared_examples_for "all combinations" do
      it "outputs correct data" do
        expected = File.open(expected_fname, "rt").read

        expect { Matr.main opts }.to output(expected).to_stdout
      end
    end

    context "handling headers in input data" do
      context "wide output" do
        it "treats first line as header by default" do
          infile = File.join TEST_FILE_DIR, "headers", "input.txt"

          opts = {
            infile:       infile,
            mode:         "ava",
            self_score:   100,
            na_replace:   nil,
            output_style: "wide",
            no_header:    false
          }

          expected = File.read File.join(TEST_FILE_DIR, "headers", "output_ignore_first_line.txt")

          expect { Matr.main opts }.to output(expected).to_stdout
        end

        it "treats first line as data if no_header is passed" do
          infile = File.join TEST_FILE_DIR, "headers", "input.txt"

          opts = {
            infile:       infile,
            mode:         "ava",
            self_score:   100,
            na_replace:   nil,
            output_style: "wide",
            no_header:    true
          }

          expected = File.read File.join(TEST_FILE_DIR, "headers", "output_keep_first_line.txt")

          expect { Matr.main opts }.to output(expected).to_stdout
        end
      end

      context "long output" do
        it "prints the header if no_header is not passed" do
          infile = File.join TEST_FILE_DIR, "headers", "with_header.txt"

          opts = {
            infile:       infile,
            mode:         "ava",
            self_score:   100,
            na_replace:   nil,
            output_style: "long",
            no_header:    false
          }

          expected = File.read File.join(TEST_FILE_DIR, "headers", "with_header_output.txt")

          expect { Matr.main opts }.to output(expected).to_stdout
        end

        it "prints NO header if no_header is passed" do
          infile = File.join TEST_FILE_DIR, "headers", "no_header.txt"

          opts = {
            infile:       infile,
            mode:         "ava",
            self_score:   100,
            na_replace:   nil,
            output_style: "long",
            no_header:    true
          }

          expected = File.read File.join(TEST_FILE_DIR, "headers", "no_header_output.txt")

          expect { Matr.main opts }.to output(expected).to_stdout
        end
      end
    end

    context "things that raise errors" do
      it "raises error with bad infile" do
        fname = "arositenaoristenoarisentoarientoiasrentoarsient"

        expect { Matr.main infile: infile(fname) }.to raise_error FATAL_ERROR
      end

      it "raises error with bad output type" do
        fname = File.join TEST_FILE_DIR, "all_combinations", "input.txt"

        expect { Matr.main infile: infile(fname), output_style: "apple" }.to raise_error FATAL_ERROR
      end

      it "raises error with mismatched scores" do
        fname = "score_mismatch.txt"

        expect { Matr.main infile: infile(fname) }.to raise_error FATAL_ERROR
      end

      it "raises error with s->t =/= t->s in ava_symmmetric mode" do
        fname = "input.score_mismatch.txt"
        expect { Matr.main infile: infile(fname), mode: "ava_symmetric" }.to raise_error FATAL_ERROR
      end
    end

    context "all combinations (ava or ava_sym, ensure self scores, na replace)" do
      let(:fname) { File.join TEST_FILE_DIR, "all_combinations", "input.txt" }

      context "ava, ensure, replace" do
        context "wide" do
          let(:opts) { make_opts(fname, "ava", true, -10) }
          let(:expected_fname) { full_path "output.ava_ensure_replace.txt" }

          include_examples "all combinations"
        end

        context "long" do
          let(:opts) { make_opts(fname, "ava", true, -10, "long") }
          let(:expected_fname) { full_path "output.ava_ensure_replace.long.txt" }

          include_examples "all combinations"
        end
      end

      context "ava, ensure, no replace" do
        context "wide" do
          let(:opts) { make_opts(fname, "ava", true, nil) }
          let(:expected_fname) { full_path "output.ava_ensure_noReplace.txt" }

          include_examples "all combinations"
        end

        context "long" do
          let(:opts) { make_opts(fname, "ava", true, nil, "long") }
          let(:expected_fname) { full_path "output.ava_ensure_noReplace.long.txt" }

          include_examples "all combinations"
        end
      end

      context "ava, no ensure, replace" do
        context "wide" do
          let(:opts) { make_opts(fname, "ava", false, -10) }
          let(:expected_fname) { full_path "output.ava_noEnsure_replace.txt" }

          include_examples "all combinations"
        end

        context "long" do
          let(:opts) { make_opts(fname, "ava", false, -10, "long") }
          let(:expected_fname) { full_path "output.ava_noEnsure_replace.long.txt" }

          include_examples "all combinations"
        end
      end

      context "ava sym, ensure, replace" do
        context "wide" do
          let(:opts) { make_opts(fname, "ava_symmetric", true, -10) }
          let(:expected_fname) { full_path "output.avaSym_ensure_replace.txt" }

          include_examples "all combinations"
        end

        context "long" do
          let(:opts) { make_opts(fname, "ava_symmetric", true, -10, "long") }
          let(:expected_fname) { full_path "output.avaSym_ensure_replace.long.txt" }

          include_examples "all combinations"
        end
      end

      context "ava, no ensure, no replace" do
        context "wide" do
          let(:opts) { make_opts(fname, "ava", false, nil) }
          let(:expected_fname) { full_path "output.ava_noEnsure_noReplace.txt" }

          include_examples "all combinations"
        end

        context "long" do
          let(:opts) { make_opts(fname, "ava", false, nil, "long") }
          let(:expected_fname) { full_path "output.ava_noEnsure_noReplace.long.txt" }

          include_examples "all combinations"
        end
      end

      context "ava sym, ensure, no replace" do
        context "wide" do
          let(:opts) { make_opts(fname, "ava_symmetric", true, nil) }
          let(:expected_fname) { full_path "output.avaSym_ensure_noReplace.txt" }

          include_examples "all combinations"
        end

        context "long" do
          let(:opts) { make_opts(fname, "ava_symmetric", true, nil, "long") }
          let(:expected_fname) { full_path "output.avaSym_ensure_noReplace.long.txt" }

          include_examples "all combinations"
        end
      end

      context "ava sym, no ensure, replace" do
        context "wide" do
          let(:opts) { make_opts(fname, "ava_symmetric", false, -10) }
          let(:expected_fname) { full_path "output.avaSym_noEnsure_replace.txt" }

          include_examples "all combinations"
        end

        context "long" do
          let(:opts) { make_opts(fname, "ava_symmetric", false, -10, "long") }
          let(:expected_fname) { full_path "output.avaSym_noEnsure_replace.long.txt" }

          include_examples "all combinations"
        end

      end

      context "ava sym, no ensure, no replace" do
        context "wide" do
          let(:opts) { make_opts(fname, "ava_symmetric", false, nil) }
          let(:expected_fname) { full_path "output.avaSym_noEnsure_noReplace.txt" }

          include_examples "all combinations"
        end

        context "long" do
          let(:opts) { make_opts(fname, "ava_symmetric", false, nil, "long") }
          let(:expected_fname) { full_path "output.avaSym_noEnsure_noReplace.long.txt" }

          include_examples "all combinations"
        end
      end
    end

    it "checks for duplicates with case sensitivity" do
      fname = "case_sensitive.txt"

      expect { Matr.main infile: infile(fname) }.not_to raise_error
    end
  end
end