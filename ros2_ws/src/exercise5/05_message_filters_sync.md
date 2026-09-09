# Exercise 5 — Multi-topic Synchronization with `message_filters`

## Objective

Synchronize messages from several sources publishing at different rates and with timestamps that don't line up exactly — a very common situation when fusing sensors (e.g. camera + IMU + lidar).

## Problem statement

Simulate **three publishers** (no real hardware needed):

- `topic_a` (`sensor_msgs::msg::Imu` or a plain `std_msgs::msg::Header`) at **50 Hz**.
- `topic_b` (same type, or `geometry_msgs::msg::PointStamped`) at **10 Hz**.
- `topic_c` (same pattern) at **30 Hz**, with timestamps slightly misaligned relative to the others (add ±5ms of random jitter to the `stamp`).

All three must carry a correctly set `header.stamp` using `this->now()` plus jitter in `topic_c`'s case.

Implement a node `sync_demo_node` with a `message_filters::Subscriber` for each topic and:

1. **First**, using `message_filters::TimeSynchronizer<MsgA, MsgB, MsgC>` (exact timestamp matching), and observe that, barring exact coincidence, **the callback almost never fires** (because timestamps don't match exactly).

2. **Then**, replace it with `message_filters::sync_policies::ApproximateTime<MsgA, MsgB, MsgC>` with a reasonable `queue_size` (e.g. 10), and verify that the callback now fires regularly, pairing up messages whose timestamps fall within a tolerance window.

In the synchronized callback, log all three received timestamps and the maximum difference between them, to confirm they're within the expected tolerance.

## Technical requirements

- You'll need the `message_filters` dependency in `package.xml`/`CMakeLists.txt`.
- Pay attention to the callback signature: it must accept `const std::shared_ptr<const MsgA>&` (or `ConstSharedPtr`) for each of the three messages, in the same order as the synchronizer.

## Expected observations

- With `TimeSynchronizer` (exact): the callback fires almost never or never, unless you force identical timestamps.
- With `ApproximateTime`: the callback fires at a rate close to that of the slowest source (10 Hz here), pairing up the closest-in-time message from each topic.
- If you increase `topic_c`'s jitter well above the tolerance window, some messages start being left without a match (they "fall out" of the synchronized group).

## Optional extension

- Vary the `queue_size` of the approximate policy and observe how it affects the rate/latency of matching.
- Add a fourth topic and test `message_filters`' limits (it typically supports synchronizing up to 9 topics with the standard templates).
