```mermaid
flowchart LR
in((In))
out((Out))
agent1[Agent1]
gate{Gate}
parallel_workflow_2_aggregator[Parallel workflow 2 Aggregator]
agent4[Agent4]
parallel_workflow_aggregator[Parallel workflow Aggregator]
agent2[Agent2]
agent3[Agent3]
agent5[Agent5]
in --> agent1
agent1 --> gate
gate -->|success| agent4
gate -->|success| agent5
gate -->|warning| agent4
gate -->|error| agent2
gate -->|error| agent3
gate -->|default| out
agent4 --> agent2
agent4 --> agent3
agent2 --> parallel_workflow_aggregator
parallel_workflow_aggregator --> parallel_workflow_2_aggregator
parallel_workflow_aggregator --> out
agent3 --> parallel_workflow_aggregator
parallel_workflow_2_aggregator --> out
agent5 --> parallel_workflow_2_aggregator
```
