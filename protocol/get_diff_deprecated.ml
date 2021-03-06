module Stable = struct

  open! Import_stable

  module Action = struct

    module V5 = struct
      type t =
        { what_feature : Maybe_archived_feature_spec.V3.t
        ; what_diff    : What_diff.V2.t
        }
      [@@deriving bin_io, fields, sexp]

      let%expect_test _ =
        print_endline [%bin_digest: t];
        [%expect {| fab5a2cdaf75e3324c227147f7ba2644 |}]
      ;;

      let to_model (t : t) = t
    end

    module V4 = struct
      type t =
        { what_feature : Maybe_archived_feature_spec.V2.t
        ; what_diff    : What_diff.V2.t
        }
      [@@deriving bin_io]

      let%expect_test _ =
        print_endline [%bin_digest: t];
        [%expect {| ae25b80d385e7de37d53926d609be34e |}]
      ;;

      let to_model { what_feature
                   ; what_diff
                   } =
        V5.to_model
          { V5.
            what_feature = Maybe_archived_feature_spec.V2.to_v3 what_feature
          ; what_diff
          }
      ;;
    end

    module V3 = struct
      type t =
        { what_feature : Maybe_archived_feature_spec.V1.t
        ; what_diff    : What_diff.V2.t
        }
      [@@deriving bin_io]

      let%expect_test _ =
        print_endline [%bin_digest: t];
        [%expect {| 91def6327f48a5796145b47efb6e5eda |}]
      ;;

      let to_model { what_feature
                   ; what_diff
                   } =
        V4.to_model
          { V4.
            what_feature = Maybe_archived_feature_spec.V1.to_v2 what_feature
          ; what_diff
          }
      ;;
    end

    module V2 = struct
      type t =
        { feature_path : Feature_path.V1.t
        ; what_diff    : What_diff.V1.t
        }
      [@@deriving bin_io]

      let%expect_test _ =
        print_endline [%bin_digest: t];
        [%expect {| 355db5d905934bc366e749ff01fb05ab |}]
      ;;

      open! Core
      open! Import

      let to_model { feature_path
                   ; what_diff
                   } =
        let what_feature =
          Maybe_archived_feature_spec.Stable.V1.existing_feature_path feature_path
        in
        V3.to_model
          { V3.
            what_feature
          ; what_diff    = What_diff.Stable.V1.to_v2 what_diff
          }
      ;;
    end

    module V1 = struct
      type t =
        { feature_path : Feature_path.V1.t
        ; reviewer     : Reviewer.V1.t
        }
      [@@deriving bin_io]

      let%expect_test _ =
        print_endline [%bin_digest: t];
        [%expect {| 1a1d64f12fcd44116dbf0831164f53e6 |}]
      ;;

      let to_model { feature_path
                   ; reviewer
                   } =
        V2.to_model
          { V2.
            feature_path
          ; what_diff =
              (match reviewer with
               | Whole_feature_reviewer              -> Whole_diff
               | Whole_feature_reviewer_plus_ignored -> Whole_diff_plus_ignored
               | Normal_reviewer user_name           -> For user_name)
          }
      ;;
    end

    module Model = V5
  end

  module Reaction = struct

    module V5 = struct
      type t =
        { feature_path     : Feature_path.V1.t
        ; feature_id       : Feature_id.V1.t
        ; is_archived      : bool
        ; diffs            : Diff2s.V2.t Or_error.V1.t Or_pending.V1.t
        ; reviewer         : Reviewer.V2.t
        ; base             : Rev.V1.t
        ; tip              : Rev.V1.t
        ; remote_rev_zero  : Rev.V1.t
        ; remote_repo_path : Remote_repo_path.V1.t
        }
      [@@deriving bin_io, sexp_of]

      let%expect_test _ =
        print_endline [%bin_digest: t];
        [%expect {| 4ed20567db8056439e20e950dd8df51d |}]
      ;;

      let of_model m = m
    end

    module V4 = struct
      type t =
        { diffs            : Diff2s.V2.t Or_error.V1.t Or_pending.V1.t
        ; reviewer         : Reviewer.V2.t
        ; base             : Rev.V1.t
        ; tip              : Rev.V1.t
        ; remote_rev_zero  : Rev.V1.t
        ; remote_repo_path : Remote_repo_path.V1.t
        }
      [@@deriving bin_io]

      let%expect_test _ =
        print_endline [%bin_digest: t];
        [%expect {| f854bab10db5bca77564da8e6b38c866 |}]
      ;;

      let of_model m =
        let { V5.
              diffs
            ; reviewer
            ; base
            ; tip
            ; remote_rev_zero
            ; remote_repo_path
            ; _
            } = V5.of_model m in
        { diffs
        ; reviewer
        ; base
        ; tip
        ; remote_rev_zero
        ; remote_repo_path
        }
      ;;
    end

    module V3 = struct
      type t =
        { diffs            : Diff2s.V2.t Or_error.V1.t Or_pending.V1.t
        ; reviewer         : Reviewer.V1.t
        ; base             : Rev.V1.t
        ; tip              : Rev.V1.t
        ; remote_rev_zero  : Rev.V1.t
        ; remote_repo_path : Remote_repo_path.V1.t
        }
      [@@deriving bin_io]

      let%expect_test _ =
        print_endline [%bin_digest: t];
        [%expect {| cf3e8b81daf420d0b232fb2bbfce2c81 |}]
      ;;

      open! Core
      open! Import

      let of_model m =
        let { V4.
              diffs
            ; reviewer
            ; base
            ; tip
            ; remote_rev_zero
            ; remote_repo_path
            } = V4.of_model m in
        { diffs
        ; reviewer =
            (if reviewer.is_whole_feature_reviewer
             then Whole_feature_reviewer
             else Normal_reviewer reviewer.user_name)
        ; base
        ; tip
        ; remote_rev_zero
        ; remote_repo_path
        }
      ;;
    end

    module V2 = struct
      type t =
        { diffs            : Diff2s.V2.t Or_error.V1.t Or_pending.V1.t
        ; base             : Rev.V1.t
        ; tip              : Rev.V1.t
        ; remote_rev_zero  : Rev.V1.t
        ; remote_repo_path : Remote_repo_path.V1.t
        }
      [@@deriving bin_io]

      let%expect_test _ =
        print_endline [%bin_digest: t];
        [%expect {| e8d1e46536209872ea54d7201c71b786 |}]
      ;;

      let of_v3 { V3. diffs; base; tip; remote_rev_zero; remote_repo_path; _ } =
        { diffs; base; tip; remote_rev_zero; remote_repo_path }
      ;;

      let of_model m = of_v3 (V3.of_model m)
    end

    module Model = V5
  end
end

include Iron_versioned_rpc.Make
    (struct let name = "get-diff" end)
    (struct let version = 7 end)
    (Stable.Action.V5)
    (Stable.Reaction.V5)

include Register_old_rpc
    (struct let version = 6 end)
    (Stable.Action.V4)
    (Stable.Reaction.V5)

include Register_old_rpc
    (struct let version = 5 end)
    (Stable.Action.V3)
    (Stable.Reaction.V5)

include Register_old_rpc
    (struct let version = 4 end)
    (Stable.Action.V2)
    (Stable.Reaction.V4)

include Register_old_rpc
    (struct let version = 3 end)
    (Stable.Action.V1)
    (Stable.Reaction.V3)

include Register_old_rpc
    (struct let version = 2 end)
    (Stable.Action.V1)
    (Stable.Reaction.V2)

module Action    = Stable.Action.   Model
module Reaction  = Stable.Reaction. Model
