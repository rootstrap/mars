```mermaid
flowchart LR
in((In))
out((Out))
llm_1[LLM 1]
gate{Gate}
parallel_workflow_2_aggregator[Parallel workflow 2 Aggregator]
llm_4[LLM 4]
parallel_workflow_aggregator[Parallel workflow Aggregator]
llm_2[LLM 2]
llm_3[LLM 3]
llm_5[LLM 5]
in --> llm_1
llm_1 --> gate
gate -->|success| llm_4
gate -->|success| llm_5
gate -->|warning| llm_4
gate -->|error| llm_2
gate -->|error| llm_3
gate -->|default| out
llm_4 --> llm_2
llm_4 --> llm_3
llm_2 --> parallel_workflow_aggregator
parallel_workflow_aggregator --> parallel_workflow_2_aggregator
parallel_workflow_aggregator --> out
llm_3 --> parallel_workflow_aggregator
parallel_workflow_2_aggregator --> out
llm_5 --> parallel_workflow_2_aggregator
```
