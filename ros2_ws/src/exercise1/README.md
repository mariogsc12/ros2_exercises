# Exercise 1 — Callback Groups + MultiThreadedExecutor

## Objective

Understand how `rclcpp` serializes or parallelizes callbacks depending on the type of *callback group* they belong to, and verify it empirically with logs.

## Problem statement

Create a node (`callback_groups_demo`) with **four timers**:

- `timer_A` and `timer_B` → belong to the **same** `MutuallyExclusive` callback group.
- `timer_C` and `timer_D` → belong to a `Reentrant` callback group (it can be the same group for both, or one each — try it both ways).

Each callback must:

1. Log a **start** timestamp (`this->now()` or `std::chrono::steady_clock`).
2. Simulate work with `std::this_thread::sleep_for(std::chrono::milliseconds(1500))` (blocking, on purpose).
3. Log an **end** timestamp.

Run the node with a `rclcpp::executors::MultiThreadedExecutor` configured with at least 4 threads (`num_threads`).

## Technical requirements

- Use `create_callback_group(rclcpp::CallbackGroupType::...)`.
- Assign each timer to its group via `rclcpp::SubscriptionOptions` / the timer's options parameter (depending on the distro, this is passed as an optional argument to `create_wall_timer`).
- Configure all four timers with the same period (e.g. every 3 seconds) so overlaps are easy to see.

## Expected observations

- `timer_A` and `timer_B` (same *MutuallyExclusive* group) should **never overlap**: the second one waits for the first to finish, even if free threads are available.
- `timer_C` and `timer_D` (*Reentrant* group) **should overlap** in time: both should show as "running" simultaneously — visible because the [start, end] interval of one crosses the other's.
- Add the `thread_id` (`std::this_thread::get_id()`) to every log line to confirm they run on different threads from the pool.

## Optional extension

- Replace one of the reentrant timers with a service, and from another process (`ros2 service call`) fire several calls in a row to see concurrency in action with real traffic, not just timers.
- Try what happens with a `SingleThreadedExecutor` using the same callback groups: confirm that **everything gets serialized** regardless of the group type (parallelism depends on the executor, not just the group).
