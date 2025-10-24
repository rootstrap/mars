```mermaid
flowchart LR
in((In))
out((Out))
parallel_workflow_aggregator[Parallel workflow Aggregator]
llm_1[LLM 1]
llm_2[LLM 2]
llm_3[LLM 3]
in --> llm_1
in --> llm_2
in --> llm_3
llm_1 --> parallel_workflow_aggregator
parallel_workflow_aggregator --> out
llm_2 --> parallel_workflow_aggregator
llm_3 --> parallel_workflow_aggregator
```
