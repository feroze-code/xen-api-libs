
(** *)
type domid = int

(* ** xenctrl.h ** *)

type vcpuinfo =
{
	online: bool;
	blocked: bool;
	running: bool;
	cputime: int64;
	cpumap: int32;
}

type runstateinfo = {
  state : int32;
  missed_changes: int32;
  state_entry_time : int64;
  time0 : int64;
  time1 : int64;
  time2 : int64;
  time3 : int64;
  time4 : int64;
  time5 : int64;
}

type domaininfo =
{
	domid             : domid;
	dying             : bool;
	shutdown          : bool;
	paused            : bool;
	blocked           : bool;
	running           : bool;
	hvm_guest         : bool;
	shutdown_code     : int;
	total_memory_pages: nativeint;
	max_memory_pages  : nativeint;
	shared_info_frame : int64;
	cpu_time          : int64;
	nr_online_vcpus   : int;
	max_vcpu_id       : int;
	ssidref           : int32;
	handle            : int array;
}

type sched_control =
{
	weight : int;
	cap    : int;
}

type physinfo =
{
	nr_cpus          : int;
	threads_per_core : int;
	cores_per_socket : int;
	sockets_per_node : int;
	nr_nodes         : int;
	cpu_khz          : int;
	total_pages      : nativeint;
	free_pages       : nativeint;
	scrub_pages      : nativeint;
	(* XXX hw_cap *)
}

type version =
{
	major : int;
	minor : int;
	extra : string;
}


type compile_info =
{
	compiler : string;
	compile_by : string;
	compile_domain : string;
	compile_date : string;
}

type shutdown_reason = Poweroff | Reboot | Suspend | Crash | Halt

type domain_create_flag = CDF_HVM | CDF_HAP

exception Error of string

type handle

(* this is only use by coredumping *)
external sizeof_core_header: unit -> int
       = "stub_sizeof_core_header"
external sizeof_vcpu_guest_context: unit -> int
       = "stub_sizeof_vcpu_guest_context"
external sizeof_xen_pfn: unit -> int = "stub_sizeof_xen_pfn"
(* end of use *)

external interface_open: unit -> handle = "stub_xc_interface_open"
external interface_close: handle -> unit = "stub_xc_interface_close"

external using_injection: unit -> bool = "stub_xc_using_injection"

let with_intf f =
	let xc = interface_open () in
	let r = try f xc with exn -> interface_close xc; raise exn in
	interface_close xc;
	r

external _domain_create: handle -> int32 -> domain_create_flag list -> int array -> domid
       = "stub_xc_domain_create"

let domain_create handle n flags uuid =
	_domain_create handle n flags (Uuid.int_array_of_uuid uuid)

external _domain_sethandle: handle -> domid -> int array -> unit
                          = "stub_xc_domain_sethandle"

let domain_sethandle handle n uuid =
	_domain_sethandle handle n (Uuid.int_array_of_uuid uuid)

external domain_setvmxassist: handle -> domid -> bool -> unit
       = "stub_xc_domain_setvmxassist"

external domain_max_vcpus: handle -> domid -> int -> unit
       = "stub_xc_domain_max_vcpus"

external domain_pause: handle -> domid -> unit = "stub_xc_domain_pause"
external domain_unpause: handle -> domid -> unit = "stub_xc_domain_unpause"
external domain_resume_fast: handle -> domid -> unit = "stub_xc_domain_resume_fast"
external domain_destroy: handle -> domid -> unit = "stub_xc_domain_destroy"

external domain_shutdown: handle -> domid -> shutdown_reason -> unit
       = "stub_xc_domain_shutdown"

external _domain_getinfolist: handle -> domid -> int -> domaininfo list
       = "stub_xc_domain_getinfolist"

let domain_getinfolist handle first_domain =
	let nb = 2 in
	let last_domid l = (List.hd l).domid + 1 in
	let rec __getlist from =
		let l = _domain_getinfolist handle from nb in
		(if List.length l = nb then __getlist (last_domid l) else []) @ l
		in
	List.rev (__getlist first_domain)

external domain_getinfo: handle -> domid -> domaininfo= "stub_xc_domain_getinfo"

external domain_get_vcpuinfo: handle -> int -> int -> vcpuinfo
       = "stub_xc_vcpu_getinfo"
external domain_get_runstate_info : handle -> int -> runstateinfo
  = "stub_xc_get_runstate_info"

external domain_ioport_permission: handle -> domid -> int -> int -> bool -> unit
       = "stub_xc_domain_ioport_permission"
external domain_iomem_permission: handle -> domid -> nativeint -> nativeint -> bool -> unit
       = "stub_xc_domain_iomem_permission"
external domain_irq_permission: handle -> domid -> int -> bool -> unit
       = "stub_xc_domain_irq_permission"

external vcpu_affinity_set: handle -> domid -> int -> int64 -> unit
       = "stub_xc_vcpu_setaffinity"
external vcpu_affinity_get: handle -> domid -> int -> int64
       = "stub_xc_vcpu_getaffinity"

external vcpu_context_get: handle -> domid -> int -> string
       = "stub_xc_vcpu_context_get"

external sched_id: handle -> int = "stub_xc_sched_id"

external sched_credit_domain_set: handle -> domid -> sched_control -> unit
       = "stub_sched_credit_domain_set"
external sched_credit_domain_get: handle -> domid -> sched_control
       = "stub_sched_credit_domain_get"

external shadow_allocation_set: handle -> domid -> int -> unit
       = "stub_shadow_allocation_set"
external shadow_allocation_get: handle -> domid -> int
       = "stub_shadow_allocation_get"

external evtchn_alloc_unbound: handle -> domid -> domid -> int
       = "stub_xc_evtchn_alloc_unbound"
external evtchn_reset: handle -> domid -> unit = "stub_xc_evtchn_reset"

external readconsolering: handle -> string = "stub_xc_readconsolering"

external send_debug_keys: handle -> string -> unit = "stub_xc_send_debug_keys"
external physinfo: handle -> physinfo = "stub_xc_physinfo"
external pcpu_info: handle -> int -> int64 array = "stub_xc_pcpu_info"

external domain_setmaxmem: handle -> domid -> int64 -> unit
       = "stub_xc_domain_setmaxmem"
external domain_set_memmap_limit: handle -> domid -> int64 -> unit
       = "stub_xc_domain_set_memmap_limit"
external domain_memory_increase_reservation: handle -> domid -> int64 -> unit
       = "stub_xc_domain_memory_increase_reservation"

external domain_set_machine_address_size: handle -> domid -> int -> unit
       = "stub_xc_domain_set_machine_address_size"
external domain_get_machine_address_size: handle -> domid -> int
       = "stub_xc_domain_get_machine_address_size"

external domain_cpuid_set: handle -> domid -> bool -> (int64 * (int64 option))
                        -> string option array
                        -> string option array
       = "stub_xc_domain_cpuid_set"
external domain_cpuid_apply: handle -> domid -> bool -> unit
       = "stub_xc_domain_cpuid_apply"
external cpuid_check: (int64 * (int64 option)) -> string option array -> (bool * string option array)
       = "stub_xc_cpuid_check"

external map_foreign_range: handle -> domid -> int
                         -> nativeint -> Mmap.mmap_interface
       = "stub_map_foreign_range"

external domain_get_pfn_list: handle -> domid -> nativeint -> nativeint array
       = "stub_xc_domain_get_pfn_list"

external domain_assign_device: handle -> domid -> (int * int * int * int) -> unit
       = "stub_xc_domain_assign_device"
external domain_deassign_device: handle -> domid -> (int * int * int * int) -> unit
       = "stub_xc_domain_deassign_device"
external domain_test_assign_device: handle -> domid -> (int * int * int * int) -> bool
       = "stub_xc_domain_test_assign_device"

external domain_suppress_spurious_page_faults: handle -> domid -> unit
       = "stub_xc_domain_suppress_spurious_page_faults"

external domain_get_acpi_s_state: handle -> domid -> int = "stub_xc_domain_get_acpi_s_state"

external domain_send_s3resume: handle -> domid -> unit = "stub_xc_domain_send_s3resume"

(** check if some hvm domain got pv driver or not *)
external hvm_check_pvdriver: handle -> domid -> bool
       = "stub_xc_hvm_check_pvdriver"

external version: handle -> version = "stub_xc_version_version"
external version_compile_info: handle -> compile_info
       = "stub_xc_version_compile_info"
external version_changeset: handle -> string = "stub_xc_version_changeset"
external version_capabilities: handle -> string =
  "stub_xc_version_capabilities"

external watchdog : handle -> int -> int32 -> int
  = "stub_xc_watchdog"

(* core dump structure *)
type core_magic = Magic_hvm | Magic_pv

type core_header = {
	xch_magic: core_magic;
	xch_nr_vcpus: int;
	xch_nr_pages: nativeint;
	xch_index_offset: int64;
	xch_ctxt_offset: int64;
	xch_pages_offset: int64;
}

external marshall_core_header: core_header -> string = "stub_marshall_core_header"

(* coredump *)
let coredump xch domid fd =
	let dump s =
		let wd = Unix.write fd s 0 (String.length s) in
		if wd <> String.length s then
			failwith "error while writing";
		in

	let info = domain_getinfo xch domid in

	let nrpages = info.total_memory_pages in
	let ctxt = Array.make info.max_vcpu_id None in
	let nr_vcpus = ref 0 in
	for i = 0 to info.max_vcpu_id - 1
	do
		ctxt.(i) <- try
			let v = vcpu_context_get xch domid i in
			incr nr_vcpus;
			Some v
			with _ -> None
	done;

	(* FIXME page offset if not rounded to sup *)
	let page_offset =
		Int64.add
			(Int64.of_int (sizeof_core_header () +
			 (sizeof_vcpu_guest_context () * !nr_vcpus)))
			(Int64.of_nativeint (
				Nativeint.mul
					(Nativeint.of_int (sizeof_xen_pfn ()))
					nrpages)
				)
		in

	let header = {
		xch_magic = if info.hvm_guest then Magic_hvm else Magic_pv;
		xch_nr_vcpus = !nr_vcpus;
		xch_nr_pages = nrpages;
		xch_ctxt_offset = Int64.of_int (sizeof_core_header ());
		xch_index_offset = Int64.of_int (sizeof_core_header ()
					+ sizeof_vcpu_guest_context ());
		xch_pages_offset = page_offset;
	} in

	dump (marshall_core_header header);
	for i = 0 to info.max_vcpu_id - 1
	do
		match ctxt.(i) with
		| None -> ()
		| Some ctxt_i -> dump ctxt_i
	done;
	let pfns = domain_get_pfn_list xch domid nrpages in
	if Array.length pfns <> Nativeint.to_int nrpages then
		failwith "could not get the page frame list";

	let page_size = Mmap.getpagesize () in
	for i = 0 to Nativeint.to_int nrpages - 1
	do
		let page = map_foreign_range xch domid page_size pfns.(i) in
		let data = Mmap.read page 0 page_size in
		Mmap.unmap page;
		dump data
	done

(* ** Misc ** *)

(**
   Convert the given number of pages to an amount in KiB, rounded up.
 *)
external pages_to_kib : int64 -> int64 = "stub_pages_to_kib"
let pages_to_mib pages = Int64.div (pages_to_kib pages) 1024L

let _ = Callback.register_exception "xc.error" (Error "register_callback")
