<script context="module">
  import { session } from '$app/stores'
  import { dlabels } from '$lib/constants'
  import { get_rtime } from '$atoms/RTime.svelte'

  import DtopicForm, { ctrl as dtopic_form } from '$parts/Dtopic/Form.svelte'
</script>

<script>
  export let topics = []
  export let dboard = {}
</script>

{#each topics as topic}
  <topic-card>
    <topic-title>
      <a
        class="topic-title"
        href="/board/-{dboard.bslug}/-{topic.tslug}-{topic.id}">
        {topic.title}
      </a>

      {#each topic.labels as label}
        <a class="m-label _{label}" href="?label={label}">{dlabels[label]}</a>
      {/each}
    </topic-title>

    <topic-brief>{topic.brief}</topic-brief>

    <topic-foot>
      <topic-user>{topic.u_dname}</topic-user>
      <topic-sep>·</topic-sep>
      <topic-time>{get_rtime(topic.ctime || 1212121200)}</topic-time>
      <topic-sep>·</topic-sep>
      <topic-repl>
        {#if topic.posts > 0}
          <span>{topic.posts} lượt trả lời</span>
        {:else}
          <span>Trả lời</span>
        {/if}
      </topic-repl>
      {#if $session.privi > 3 || $session.uname == topic.u_dname}
        <topic-sep>·</topic-sep>
        <topic-action on:click={() => dtopic_form.show(topic.id)}>
          <span>Sửa</span>
        </topic-action>
      {/if}
    </topic-foot>
  </topic-card>
{:else}
  <div class="empty">
    <h4>Chưa có chủ đề thảo luận :(</h4>
  </div>
{/each}

{#if dtopic_form.actived}<DtopicForm {dboard} />{/if}

<style lang="scss">
  .empty {
    height: 20rem;
    max-height: 50vh;
    display: flex;
    align-items: center;
    justify-content: center;
    text-align: center;
    font-style: italic;
    @include ftsize(lg);
    @include fgcolor(mute);
  }

  topic-card {
    display: block;

    @include border(--bd-main, $loc: bottom);
    &:first-of-type {
      @include border(--bd-main, $loc: top);
    }

    > * {
      padding-left: var(--gutter);
      padding-right: var(--gutter);
    }
  }

  topic-title {
    display: block;
    padding-top: 0.5rem;

    @include bps(font-size, rem(16px), rem(17px));

    cursor: pointer;
    &:hover .topic-title {
      @include fgcolor(primary, 5);
    }
  }

  topic-brief {
    display: block;
    @include fgcolor(tert);
  }

  topic-foot {
    @include flex($gap: 0.25rem);
    line-height: 2rem;
    @include ftsize(sm);
    @include fgcolor(secd);
  }

  topic-time {
    @include clamp($width: null);
  }

  topic-user {
    font-weight: 200;
    // @include ftsize(md);
  }

  .topic-title {
    @include ftsize(lg);
    @include fgcolor(secd);
    word-wrap: break-word;

    font-weight: 500;
    line-height: 1.5rem;
  }

  topic-repl {
    font-style: italic;
    cursor: pointer;
    @include hover {
      @include fgcolor(primary, 5);
      text-decoration: underline;
    }
  }

  topic-action {
    cursor: pointer;
  }

  .m-label + .m-label {
    margin-left: 0.25rem;
  }
</style>
