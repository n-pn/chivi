<script lang="ts">
  import { dboard_ctrl } from '$lib/stores'
  import { rel_time } from '$utils/time_utils'

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let cvpost: CV.Cvpost
  export let _mode = 0

  $: dboard = cvpost.dboard
  $: board_url = `/forum/-${dboard.bslug}`
  $: label_url = _mode > -1 ? board_url : `/-${dboard.bslug}/board`
</script>

<topic-card class:sm={$$props.size == 'sm'}>
  <topic-head class={_mode}>
    <a
      class="topic-title"
      href="{board_url}/-{cvpost.tslug}-{cvpost.id}"
      on:click={(e) => dboard_ctrl.view_topic(e, cvpost)}>
      {cvpost.title}
    </a>

    {#each cvpost.labels as label, index}
      <a
        class="m-label _{index + 1} _sm"
        href="{label_url}?lb={label}"
        on:click={(e) => dboard_ctrl.view_board(e, dboard, label)}>{label}</a>
    {/each}
  </topic-head>

  <topic-brief>
    {#if cvpost.lp_uname}
      <span><SIcon name="corner-up-left" /></span>
      <cv-user data-privi={cvpost.lp_privi}>{cvpost.lp_uname}</cv-user>
      <span>·</span>
      <topic-time>{rel_time(cvpost.ctime)}</topic-time>
    {:else}
      <span><SIcon name="send" /></span>
      <cv-user data-privi={cvpost.op_privi}>{cvpost.op_uname}</cv-user>
      <span>·</span>
      <topic-time>{rel_time(cvpost.ctime)}</topic-time>
    {/if}
    <topic-sep>·</topic-sep>

    <span class="brief">{cvpost.brief}</span>
  </topic-brief>

  <topic-foot>
    {#if _mode > 0}
      <a
        class="m-board"
        href={board_url}
        on:click={(e) => dboard_ctrl.view_board(e, dboard)}>
        <SIcon name="message" />
        <span>{dboard.bname}</span>
      </a>
    {/if}

    <foot-right>
      <topic-meta>
        <SIcon name="eye" />
        <span>{cvpost.view_count}</span>
      </topic-meta>

      <topic-meta>
        <SIcon name="messages" />
        <span>{cvpost.post_count}</span>
      </topic-meta>

      <topic-meta>
        <SIcon name="star" />
        <span>{cvpost.like_count}</span>
      </topic-meta>
    </foot-right>
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
    flex-wrap: wrap;

    padding-top: 0.5rem;
    line-height: 1.5rem;

    topic-card.sm & {
      @include ftsize(md);
      // padding-top: 0.375rem;
      // padding-bottom: 0.25rem;
      line-height: 1.375rem;
    }
  }

  .topic-title {
    font-weight: 500;

    @include fgcolor(secd);
    @include ftsize(lg);

    topic-card:hover & {
      @include fgcolor(primary, 5);
    }
  }

  topic-brief {
    @include clamp($lines: 2);
    line-height: 1.25rem;
    padding: 0.25rem 0;
    word-wrap: break-word;

    topic-card.sm & {
      @include ftsize(sm);
    }
  }

  .brief {
    font-style: italic;
    @include fgcolor(secd);
  }

  topic-foot {
    @include flex-cy($gap: 0.25rem);
    // line-height: 2rem;

    line-height: 1.375rem;
    padding-bottom: 0.25rem;
    @include ftsize(sm);
    @include fgcolor(tert);
  }

  .m-board {
    @include clamp($width: null);
    max-width: 40vw;

    @include fgcolor(tert);

    @include hover {
      @include fgcolor(primary, 5);
    }
  }

  foot-right {
    margin-left: auto;
    @include flex-cy($gap: 0.5rem);
  }

  topic-time {
    @include clamp($width: null);
  }

  topic-meta {
    @include flex-cy;
    gap: 0.25rem;
  }
</style>
