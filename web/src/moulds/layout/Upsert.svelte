<script context="module">
  const fixture = '宋师兄'
  export async function preload({ query }) {
    return { input: query.input || fixture }
  }

  export function gen_links(input) {
    return [
      { site: 'iCIBA', href: `https://www.iciba.com/${input}` },
      {
        site: 'Google Translation',
        href: `https://translate.google.com/#view=home&op=translate&sl=zh-CN&tl=vi&text=${input}`,
      },
      {
        site: 'Google',
        href: `https://www.google.com/search?q=${input}`,
      },
      {
        site: 'Baidu Fanyi',
        href: `https://fanyi.baidu.com/#zh/en/${input}`,
      },
      {
        site: 'Baike',
        href: `https://baike.baidu.com/item/${input}`,
      },
    ]
  }
</script>

<script>
  import { onMount, afterUpdate } from 'svelte'

  const dnames = ['common', 'unique']

  export let input = ''
  export let dname = 'unique'

  $: links = gen_links(input)

  $: if (input !== '') fetch_data(input)
  onMount(() => value_input.focus())
  // afterUpdate(() => fetch_data(input))

  let data = {
    chinese: '',
    hanviet: [],
    pinyins: '',
    common: {},
    unique: {},
    suggest: [],
  }

  let value_input = null
  $: value = data[dname].val || ''
  $: suggest = data.suggest[0] || data.hanviet.join(' ')

  async function fetch_data(input) {
    if (!fetch) return
    const res = await fetch('/api/inquire', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ input }),
    })
    data = await res.json()
  }

  function change_tab(name) {
    dname = name
    value_input.focus()
    // const input = document.getElementById(`output-${name}`)
    // setTimeout(() => input.focus(), 0)
  }

  function capitalize(num = 100) {
    const vals = value.split(' ')
    console.log(value)

    if (num > vals.length) num = vals.length

    for (let i = 0; i < num; i++) {
      vals[i] = vals[i].charAt(0).toUpperCase() + vals[i].slice(1)
    }
    for (let i = num; i < vals.length; i++) {
      vals[i] = vals[i].toLowerCase()
    }

    console.log(vals)
    value = vals.join(' ')
  }
</script>

<style lang="scss">
  .wrap {
    position: fixed;
    display: flex;
    align-items: center;
    justify-content: center;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    z-index: 9999;
    background-color: rgba(#000, 0.1);
  }

  .dialog {
    width: rem(432);
    max-width: 100%;
    background-color: #fff;
    margin-top: -10%;
    @include corner(md);
    @include shadow(lg);
  }

  $label-width: 3rem;
  .chinese {
    // display: flex;
    padding-top: 0.5rem;
    input {
      display: block;
      @include bgcolor(neutral, 1);
      border: 1px solid color(neutral, 2);
      width: 100%;
      // width: calc(100% - #{$label-width});
      margin-left: auto;
      padding: 0 1rem;
      line-height: 2.5rem;
      @include corner(md);
      &:focus {
        background-color: #fff;
        @include bdcolor(primary, 3);
      }
      // line-height: 1rem;
    }
  }

  .translit {
    // margin-left: $label-width + 0.5rem;
    margin: 0;
    padding-top: 0.5rem;
    // padding: 0.5rem;
    // padding-bottom: 0;
    @include font-size(sm);
    @include color(neutral, 7);
  }

  header {
    @include bgcolor(neutral, 1);
    @include corner-top(md);
    padding: 0 1rem;
    border-bottom: 1px solid color(neutral, 2);
    height: 2.5rem;
  }

  .tab-name {
    display: inline-block;
    text-transform: uppercase;
    @include font-size(sm);
    @include color(neutral, 6);
    // @include corner-top(md);
    font-weight: 500;
    height: 2.5rem;
    line-height: 2.5rem;
    padding: 0 1rem;
    // margin-top: 1px;

    border: 1px solid transparent;
    // border-top: 0;
    border-bottom: 0;
    // border: 1px solid color(neutral, 2);
    &._active {
      // border-bottom-color: color(primary, 3);
      @include color(primary, 6);
      background-color: #fff;

      border-left: 1px solid color(neutral, 2);
      border-right: 1px solid color(neutral, 2);
      @include bdcolor(neutral, 2);
      border-top-color: color(primary, 5);
    }

    @include hover {
      cursor: pointer;
    }
  }

  .zhinput {
    padding: 0.5rem 1rem;
    border-bottom: 1px solid color(neutral, 2);
  }

  .value {
    padding: 1rem;
  }

  .value-footer {
    margin: 1rem 0;
    display: flex;
    .left {
      margin-right: auto;
    }
    .right {
      margin-left: auto;
    }
  }

  .links {
    display: flex;
    @include bgcolor(neutral, 1);
    @include corner-bottom(md);
    // width: 5rem;
    margin: 0;
    padding: 0 0.5rem;
    border-top: 1px solid color(neutral, 2);
    text-align: center;

    span,
    a {
      // display: inline-block;
      line-height: 1rem;
      padding: 0.5rem;
      @include font-size(sm);
      @include font-family(narrow);
    }

    a {
      @include color(neutral, 7);
      display: inline-block;
      border-left: 1px splid color(neutral, 3);

      @include hover {
        cursor: pointer;
        background-color: color(neutral, 3);
      }
    }
  }

  .value-input {
    display: block;
    width: 100%;
    @include corner(md);
    @include border(color(neutral, 2));
    padding: 0.5rem 1rem;
    margin: 0;
    @include bgcolor(neutral, 1);
    min-height: 2.75rem;
    &:focus,
    &:active {
      background-color: #fff;
      @include bdcolor(primary, 3);
    }
  }

  .value-edit {
    display: flex;
    margin-bottom: 0.5rem;
    .cap {
      @include color(neutral, 5);
      // padding-right: 0.25rem;
    }
    .act {
      @include corner(md);
      margin-left: 0.25rem;
      padding: 0 0.5rem;
      @include color(neutral, 6);
      @include border(color(neutral, 3));
      @include hover {
        cursor: pointer;
        @include color(primary, 6);
      }
    }
    span {
      display: inline-block;

      line-height: 1.5rem;
      @include font-size(sm);
      // @include truncate();
      @include font-family(narrow);
    }
  }
</style>

<div class="wrap">
  <div class="dialog">
    <header>
      {#each dnames as name}
        <span
          class="tab-name"
          class:_active={dname == name}
          on:click={() => change_tab(name)}>
          {name == 'common' ? 'Vietphrase' : 'Tên riêng'}
        </span>
      {/each}
    </header>
    <section class="zhinput">
      <div class="chinese">
        <input type="text" name="chinese" bind:value={input} />
      </div>
      <div class="translit">
        <span class="pinyins">[{data.pinyins}]</span>
        <span class="hanviet">{data.hanviet.join(' ')}</span>
      </div>
    </section>

    <section class="value">
      <div class="value-edit">
        <span class="cap">Viết hoa:</span>
        <span class="act" on:click={() => capitalize(1)}>1 chữ đầu</span>
        <span class="act" on:click={() => capitalize(2)}>2 chữ đầu</span>
        <span class="act" on:click={() => capitalize(3)}>3 chữ đầu</span>
        <span class="act" on:click={() => capitalize(99)}>toàn bộ</span>
        <span class="act" on:click={() => capitalize(0)}>không</span>
      </div>
      <textarea
        lang="vi"
        class="value-input"
        name="value"
        id="value_input"
        rows="2"
        bind:this={value_input}
        value={value || suggest} />

      <div class="value-footer">
        <div class="left">
          <button class="m-btn _fill">Undo</button>
        </div>
        <div class="right">
          <button class="m-btn _primary">{value ? 'Update' : 'Add'}</button>
          <button class="m-btn _text _red">Delete</button>
        </div>

      </div>

    </section>

    <div class="links">
      <span>Links:</span>
      {#each links as { site, href }}
        <a {href} target="_blank">{site}</a>
      {/each}
    </div>
  </div>
</div>
