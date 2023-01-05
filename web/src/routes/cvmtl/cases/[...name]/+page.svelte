<script lang="ts">
  import type { PageData } from './$types'

  export let data: PageData
</script>

<article class="article island">
  <table class="m-table">
    <thead>
      <tr>
        <th>Input</th>
        <th>Cvmtl</th>
        <th>Correct</th>
      </tr>
    </thead>

    <tbody>
      {#each data.cases as { input, expect, actual }}
        {@const match = expect.includes(actual)}

        <tr class="case" class:match>
          <td class="input">{input}</td>
          <td class="actual">{actual}</td>
          <td class="expect">{expect.join(' / ')}</td>
        </tr>
      {/each}
    </tbody>
  </table>
</article>

<style lang="scss">
  article {
    margin-top: var(--gutter);
    padding: var(--gutter);
  }

  .case {
    line-height: 1.25rem;

    // line-height: 2rem;
    @include fgcolor(harmful, 5);

    &.match {
      @include fgcolor(success, 5);
    }
  }

  .input {
    @include ftsize(sm);
  }

  .actual {
    font-size: rem(15px);
  }

  .expect {
    @include ftsize(sm);
  }
</style>
