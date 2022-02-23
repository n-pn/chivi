<script lang="ts">
  import { rel_time } from '$utils/time_utils'
  import { dlabels } from '$lib/constants'

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let dtopic: CV.Dtopic
  export let dboard: CV.Dboard = dtopic.dboard
  export let _mode = 0

  $: board_url = `/forum/-${dboard.bslug}`
  $: label_url = _mode > -1 ? board_url : `/-${dboard.bslug}/board`
</script>

<topic-card class:sm={$$props.size == 'sm'}>
  <topic-head class={_mode}>
    {#if _mode > 0}
      <a class="m-board" href={board_url}>
        <SIcon name="message" />
        <span>{dboard.bname}</span>
      </a>
    {/if}

    <topic-labels>
      {#each dtopic.labels as label}
        <a class="m-label _{label} _sm" href="{label_url}?tl={label}"
          >{dlabels[label]}</a>
      {/each}
    </topic-labels>
  </topic-head>

  <a class="topic-title" href="{board_url}/-{dtopic.tslug}-{dtopic.id}">
    {dtopic.title}
  </a>

  <topic-brief>{dtopic.brief}</topic-brief>

  <topic-foot>
    <topic-user>
      <cv-user data-privi={dtopic.u_privi}>{dtopic.u_dname}</cv-user>
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
    @include padding-x(0.75rem);
    @include bdradi;
    @include border(--bd-main);
  }

  topic-head {
    @include flex-cy($gap: 0.25rem);
    padding: 0.25rem 0;
    @include border($loc: bottom);
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

  topic-labels {
    @include flex($gap: 0.25rem);
    margin-left: auto;
  }

  .m-label {
    @include clamp($width: null);
  }

  .topic-title {
    display: block;
    font-weight: 500;
    padding-top: 0.5rem;
    padding-top: 0.375rem;
    line-height: 1.5rem;

    @include fgcolor(secd);
    @include ftsize(lg);

    topic-card.sm & {
      @include ftsize(md);
      padding-top: 0.375rem;
      padding-bottom: 0.25rem;
      line-height: 1.375rem;
    }

    topic-head .topic-title {
      @include fgcolor(primary, 5);
    }
  }

  topic-brief {
    display: block;
    font-style: italic;
    @include clamp($lines: 2);
    @include fgcolor(secd);
    line-height: 1.25rem;

    topic-card.sm & {
      @include ftsize(sm);
    }
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
