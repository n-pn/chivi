<script context="module">
  const stats = ['Thu nhỏ xuống', 'Trạng thái thường', 'Phóng to hết cỡ']
  const icons = ['minimize', 'resize', 'maximize']
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let title = ''
  export let state = 1
  export let lines = 3
</script>

<section>
  <h4>
    <span class="title">{title}</span>
    <span class="tools">
      <slot name="tools" />

      {#each icons as icon, new_state}
        <button
          class="-btn"
          class:_active={state == new_state}
          on:click={() => (state = new_state)}
          data-tip={stats[new_state]}
          data-tip-loc="bottom"
          data-tip-pos="right">
          <SIcon name={icon} />
        </button>
      {/each}
    </span>
  </h4>

  <div class="wbody cdata {$$props.class} _{state}" style="--lc: ${lines}">
    <slot />
  </div>
</section>

<style lang="scss">
  h4 {
    display: flex;
    margin-top: 0.5rem;
    margin-bottom: 0.25rem;
    @include ftsize(sm);

    // padding: 0 0.75rem;
    font-weight: 500;
    line-height: 1rem;
  }

  .tools {
    @include flex-cy;
    margin-left: auto;
    gap: 0.125em;

    > :global(.-btn) {
      background-color: inherit;
      @include fgcolor(tert);
      font-style: italic;
      font-weight: 400;

      &._active,
      &:hover {
        @include fgcolor(primary, 5);
      }
      &:disabled {
        @include fgcolor(mute);
      }
    }
  }

  .wbody {
    padding: 0.25rem 0.5rem;

    text-align: justify;
    text-justify: auto;

    --lh: 1.25em;
    line-height: var(--lh);

    @include bgcolor(tert);

    @include border;
    @include bdradi;

    &._0,
    &._1 {
      @include scroll;
    }

    &._0 {
      max-height: calc(var(--lh) + 0.55rem);
    }

    &._1 {
      max-height: calc(var(--lh) * var(--lc, 3) + 0.5rem);
    }

    &._lg {
      @include ftsize(lg);
    }

    &._sm {
      @include ftsize(sm);
    }

    &._ct {
      overflow-x: scroll;
    }
  }

  //   &:global(._zh) {
  //     $line: 1.5rem;
  //     line-height: $line;

  //     &._1 {
  //       max-height: $line * 3 + 0.75rem;
  //     }
  //   }

  //   &._mt {
  //     $line: 1.25rem;
  //     line-height: $line;
  //     max-height: $line * 6 + 0.75rem;
  //     font-size: rem(17px);
  //   }

  //   &._tl {
  //     $line: 1.125rem;
  //     line-height: $line;
  //     max-height: $line * 5 + 0.75rem;
  //     font-size: rem(15px);
  //   }

  //   &._ct {
  //     $line: 1.25rem;
  //     line-height: $line;
  //     overflow-y: visible;

  //     :global(x-n) {
  //       color: var(--active);
  //       font-weight: 450;
  //       border: 0;
  //       &:hover {
  //         border-bottom: 1px solid var(--border);
  //       }
  //     }
  //   }
  // }
</style>
