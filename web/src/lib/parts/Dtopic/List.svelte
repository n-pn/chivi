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
    <topic-head>
      <topic-labels>
        {#each topic.labels as label}
          <a class="m-label _{label}" href="?label={label}">{dlabels[label]}</a>
        {/each}
      </topic-labels>

      <a
        class="topic-title"
        href="/board/-{dboard.bslug}/-{topic.tslug}-{topic.id}">
        {topic.title}
      </a>
    </topic-head>

    <topic-brief>{topic.brief}</topic-brief>

    <topic-foot>
      <foot-left>
        <topic-user>
          <cv-user privi={topic.u_privi}>{topic.u_dname}</cv-user>
        </topic-user>
        <topic-sep>·</topic-sep>
        <topic-time>{get_rtime(topic.ctime || 1212121200)}</topic-time>
      </foot-left>

      <foot-right>
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
      </foot-right>
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

  topic-head {
    display: block;
    padding-top: 0.5rem;
    cursor: pointer;

    @include bps(font-size, rem(16px), rem(17px));
    @include flow();
  }

  topic-labels {
    float: right;
  }

  .m-label {
    line-height: 1.375rem;
    font-size: rem(13px);
    margin-left: 0.25rem;
  }

  .topic-title {
    font-weight: 500;
    line-height: 1.5rem;

    @include fgcolor(secd);
    @include ftsize(lg);

    topic-head .topic-title {
      @include fgcolor(primary, 5);
    }
  }

  topic-brief {
    display: block;
    @include fgcolor(secd);
    font-style: italic;
  }

  topic-foot {
    @include flex($gap: 0.25rem);
    // line-height: 2rem;
    margin: 0.25rem 0;
    @include ftsize(sm);
    @include fgcolor(tert);
  }

  foot-left,
  foot-right {
    @include flex-cy($gap: 0.25rem);
  }

  foot-right {
    margin-left: auto;
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

  .m-label + .m-label {
    margin-left: 0.25rem;
  }
</style>
