<script lang="ts">
  import { rel_time } from '$utils'
  import { dlabels } from '$lib/constants'

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let dtopic
  export let _mode = 0

  $: board_url = `/forum/-${dtopic.dboard.bslug}`
  $: label_url = _mode > -1 ? board_url : `/-${dtopic.dboard.bslug}/board`
</script>

<topic-card>
  <topic-head class={_mode}>
    {#if _mode > 0}
      <a class="m-board" href={board_url}>
        <SIcon name="messages" />
        <span>{dtopic.dboard.bname}</span>
      </a>
    {/if}

    {#each dtopic.labels as label}
      <a class="m-label _{label}" href="{label_url}?tl={label}"
        >{dlabels[label]}</a>
    {/each}
  </topic-head>

  <a class="topic-title" href="{board_url}/-{dtopic.tslug}-{dtopic.id}">
    {dtopic.title}
  </a>

  <topic-brief>{dtopic.brief}</topic-brief>

  <topic-foot>
    <topic-user>
      <cv-user privi={dtopic.u_privi}>{dtopic.u_dname}</cv-user>
    </topic-user>

    <topic-sep>·</topic-sep>
    <topic-time>{rel_time(dtopic.ctime)}</topic-time>

    <topic-sep>·</topic-sep>
    <topic-meta>
      <SIcon name="messages" />
      <span>{dtopic.post_count}</span>
    </topic-meta>

    <topic-sep>·</topic-sep>
    <topic-meta>
      <SIcon name="eye" />
      <span>{dtopic.view_count}</span>
    </topic-meta>

    <topic-sep>·</topic-sep>
    <topic-meta>
      <SIcon name="star" />
      <span>{dtopic.like_count}</span>
    </topic-meta>
  </topic-foot>
</topic-card>

<style lang="scss">
  topic-card {
    display: block;

    @include border(--bd-main, $loc: bottom);
  }

  topic-head {
    @include flex-cy($gap: 0.25rem);
    padding: 0.5rem 0 0.25rem;
  }

  .m-board {
    @include clamp($width: null);
    max-width: 40vw;

    line-height: 1.375rem;
    @include fgcolor(tert);

    @include ftsize(sm);
    @include hover {
      @include fgcolor(primary, 5);
    }
  }

  .m-label {
    font-size: rem(12px);
    padding: 0 0.375rem;
    line-height: 1.25rem;
  }

  .topic-title {
    display: block;
    font-weight: 500;
    line-height: 1.5rem;
    padding: 0.25rem 0;

    @include fgcolor(secd);
    @include ftsize(lg);

    topic-head .topic-title {
      @include fgcolor(primary, 5);
    }
  }

  topic-brief {
    display: block;
    font-style: italic;
    @include fgcolor(secd);
  }

  topic-foot {
    @include flex-cy($gap: 0.25rem);
    // line-height: 2rem;

    padding: 0.5rem 0 0.25rem;
    @include ftsize(sm);
    @include fgcolor(tert);
  }

  topic-time {
    @include clamp($width: null);
  }

  topic-meta {
    @include flex-cy;
    gap: 0.25rem;
  }
</style>
