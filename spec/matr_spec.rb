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

    # This is how trollop will pass in args.
    na_replace:         na_replace ? na_replace : nil,
    na_replace_given:   na_replace ? true : nil,
    output_style:       output_style
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