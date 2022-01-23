<script>
  import { session } from '$app/stores'
  import { rel_time } from '$lib/utils'
  import { dlabels } from '$lib/constants'

  import SIcon from '$atoms/SIcon.svelte'
  import { ctrl as dtopic_form } from '$parts/Dtopic/Form.svelte'

  export let dtopic
  export let _mode = 0

  $: board_url = `/forum/-${dtopic.b_bslug}`
  $: label_url = _mode > -1 ? board_url : `/-${dtopic.b_bslug}/board`
</script>

<topic-card>
  <topic-head class={_mode}>
    {#if _mode > 0}
      <a class="m-board" href={board_url}>
        <SIcon name="messages" />
        <span>{dtopic.b_bname}</span>
      </a>
    {/if}

    {#each dtopic.labels as label}
      <a class="m-label _{label}" href="{label_url}?label={label}"
        >{dlabels[label]}</a>
    {/each}
  </topic-head>

  <a class="topic-title" href="{board_url}/-{dtopic.tslug}-{dtopic.id}">
    {dtopic.title}
  </a>

  {#if _mode == 3}
    <topic-pbody class="m-article">{@html dtopic.bhtml}</topic-pbody>
  {:else}
    <topic-brief>{dtopic.brief}</topic-brief>
  {/if}

  <topic-foot>
    <topic-user>
      <cv-user privi={dtopic.u_privi}>{dtopic.u_dname}</cv-user>
    </topic-user>
    <topic-sep>·</topic-sep>
    <topic-time>{rel_time(dtopic.ctime)}</topic-time>

    <topic-sep>·</topic-sep>

    <topic-repl>
      {#if dtopic.posts > 0}
        <span>{dtopic.posts} lượt trả lời</span>
      {:else}
        <span>Trả lời</span>
      {/if}
    </topic-repl>
    {#if $session.privi > 3 || $session.uname == dtopic.u_dname}
      <topic-sep>·</topic-sep>
      <topic-action on:click={() => dtopic_form.show(dtopic.id)}>
        <span>Sửa</span>
      </topic-action>
    {/if}
  </topic-foot>
</topic-card>

<style lang="scss">
  topic-card {
    display: block;

    @include border(--bd-main, $loc: bottom);

    > * {
      margin-left: var(--gutter);
      margin-right: var(--gutter);
    }
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

  topic-pbody,
  topic-brief {
    display: block;
  }

  topic-brief {
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

  topic-repl {
    cursor: pointer;
    font-style: italic;

    @include hover {
      @include fgcolor(primary, 5);
      text-decoration: underline;
    }
  }

  topic-action {
    cursor: pointer;
    font-style: italic;

    @include hover {
      @include fgcolor(primary, 5);
    }
  }
</style>
